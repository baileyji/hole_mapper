from ConfigParser import RawConfigParser
import os.path
from glob import glob
from plate import get_plate
from cassettes import CassetteConfig
from cassettes import CASSETTE_NAMES, RED_CASSETTE_NAMES, BLUE_CASSETTE_NAMES
from pathconf import CONFIGDEF_DIRECTORY, SETUP_DIRECTORY
from readerswriters import _dictlist_to_records, _format_attrib_nicely
from logger import getLogger
from config import get_config

log = getLogger('setup')



REQUIRED_PLUGGED_SECTION_KEYS=['fiber', 'id', 'ra', 'dec', 'epoch', 'type',
                               'priority','pm_ra','pm_dec','x','y','z','d']
REQUIRED_GUIDE_SECTION_KEYS=['id', 'ra', 'dec', 'epoch', 'type',
                             'priority','pm_ra','pm_dec','x','y','z','d']
REQUIRED_UNUSED_SECTION_KEYS=['id', 'ra', 'dec', 'epoch', 'type',
                              'priority','pm_ra','pm_dec','x','y','z','d']


def load_dotsetup(file):
    #Read in the setup definitions
    cp=RawConfigParser()
    cp.optionxform=str
    with open(file) as fp:
        cp.readfp(fp)
    
    setupdefs=[]
    
    for section in cp.sections():
        section_dict=dict(cp.items(section))
        setupdefs.append(SetupDefinition(file, section_dict.pop('plate'),
                                         section_dict.pop('field'),
                                         section_dict.pop('config'),
                                         section_dict.pop('assign_to'),
                                         extra=section_dict))
    return setupdefs


def _load_setups():
    setupfiles=glob(SETUP_DIRECTORY+'*.setup')
    for f in setupfiles:
        _KNOWN_SETUPS.update({s.name:s for s in load_dotsetup(f)})


def get_setup(setupname):
    try:
        setup_def=_KNOWN_SETUPS[setupname]
    except KeyError:
        _load_setups()
        if setupname in _KNOWN_SETUPS:
            setup_def=_KNOWN_SETUPS[setupname]
        else:
            raise ValueError('Could not find setup {}'.format(setupname))

    #Create setup from setupdef
    try:
        config=get_config(setup_def.configname)
    except ValueError as e:
        raise e

    try:
        plate=get_plate(setup_def.platename)
    except ValueError as e:
        raise e

    return Setup(setup_def, plate, config)

def get_setups_for_plate(platename):
    _load_setups()
    return [name for name, sdef in _KNOWN_SETUPS.items()
            if sdef.platename==platename]

def get_all_setups():
    _load_setups()
    return [get_setup(name) for name in _KNOWN_SETUPS]

class SetupDefinition(object):
    def __init__(self, file, platename, fieldname, configname, assign_to,
                 extra=None):
        self.file=file
        self.platename=platename
        self.fieldname=fieldname
        self.configname=configname
        self.assign_to=assign_to.lower()
        if self.assign_to not in ['single', 'any']:
            raise ValueError('Supported values for assign_to are '
                             'single and any. Fix file {}'.format(self.file))
        self.extra=extra if extra else {}
    
    @property
    def name(self):
        return '{}:{}:{}'.format(self.platename, self.fieldname,
                                 self.configname)


class Setup(object):
    def __init__(self, setupdef, plate, config):
    
        self.file=setupdef.file
        
        self.name=setupdef.name
        
        self.config=config
        
        self.assign_to=setupdef.assign_to

        self.plate=plate

        #Fetch Field from plate
        self.field=self.plate.get_field(setupdef.fieldname)
        
        #Fetch cassettes
        self.cassette_config=CassetteConfig(usableR=config.r.active_fibers,
                                            usableB=config.b.active_fibers)

    def reset(self):
        self.config=get_config(self.config.name)
        for t in self.field.skys+self.field.targets:
            t.reset_assignment()
        self.cassette_config=CassetteConfig(usableR=self.config.r.active_fibers,
                                            usableB=self.config.b.active_fibers)

    @property
    def info(self):
        ret=self.field.info.copy()
    
        addit={'assign_with':', '.join(s.name for s in self.assign_with),
               'plate':self.plate.name, 'config':self.config.name,
               'name':self.name}
        
        for k in addit:
            assert k not in ret

        ret.update(addit)
        
        return ret
    
    @property
    def uses_b_side(self):
        """ returns true iff targets have been assigned to b side"""
        for t in self.field.skys+self.field.targets:
            if t.fiber and t.fiber.color=='b':
                return True
        return False

    @property
    def uses_r_side(self):
        """ returns true iff targets have been assigned to r side"""
        for t in self.field.skys+self.field.targets:
            if t.fiber and t.fiber.color=='r':
                return True
        return False
    
    @property
    def n_usable_fibers(self):
        """number of fibers usable when instrument configured for this setup"""
        #TODO: Implement
        return 256

    @property
    def n_needed_fibers(self):
        """number of fibers usable when instrument configured for this setup"""
        #TODO: Implement
        return 256

    def writemap(self, dir='./'):
        """
        [setup]
        field & config info
        [assignments]
        header
        records
        [guides]
        header
        records
        [unused]
        header
        records
        """
        filename='{}.fibermap'.format(self.name)

        with open(os.path.join(dir, filename),'w') as fp:
    
            fp.write("[setup]\n")

            for r in _format_attrib_nicely(self.info):
                fp.write(r)
    
            #Fibers assigned and unassigned
            fp.write("[assignments]\n")

            def dicter(fiber):
                """ convert a fiber assignment into a dictlist record """
                if not f.target:
                    return {'fiber':fiber.name,'id':'unplugged'}
                elif f.target not in self.field.all_targets:
                    return {'fiber':fiber.name,'id':'unassigned'}
                else:
                    return fiber.target.dict

            #Grab fibers
            dl=[dicter(f) for f in self.cassette_config.fibers]
            recs=_dictlist_to_records(dl,
                                      col_first=REQUIRED_PLUGGED_SECTION_KEYS)
            for r in recs:
                fp.write(r)
    
            #Write guides and acquisitions
            fp.write("[guides]\n")
            dl=[t.dict for t in self.field.guides+self.field.acquisitions]
            recs=_dictlist_to_records(dl, col_first=REQUIRED_GUIDE_SECTION_KEYS)
            for r in recs:
                fp.write(r)

            #All the other targets
            fp.write("[unused]\n")
            dl=[t.dict for t in self.field.skys+self.field.targets
                if not t.fiber]
            recs=_dictlist_to_records(dl, col_first=REQUIRED_UNUSED_SECTION_KEYS)
            for r in recs:
                fp.write(r)
            #TODO: target record for any targets not on plate on unassigned

    def write(self,dir='./'):
        """ Call to write the outputs after calling assign"""
        self.writemap(dir=dir)
        self.config.write_plist(self.name+'m2fs', dir=dir)
    
#        for s in self.assign_with:
#            s.writemap(dir=dir)
#            s.writeplist(dir=dir)








_KNOWN_SETUPS={}
_load_setups()


