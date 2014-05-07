#!/usr/bin/env python
import Tkinter
import ttk
import BetterCanvas
import os
import argparse
import fieldmanager
from dimensions import PLATE_RADIUS
from ttkcalendar import date_time_picker
import tkFileDialog
from datetime import datetime
from logger import getLogger
from errors import ConstraintError
import tkMessageBox
log=getLogger('plateplanner')


def parse_cl():
    parser = argparse.ArgumentParser(description='Help undefined',
                                     add_help=True)
    parser.add_argument('-p','--port', dest='PORT',
                        action='store', required=False, type=int,
                        help='')
    parser.add_argument('--log', dest='LOG_LEVEL',
                        action='store', required=False, default='',
                        type=str,
                        help='')
    return parser.parse_args()


class FieldSettingsDialog(object):
    def __init__(self, parent, field):
        self.parent=parent
        self.field=field
        self.dialog=Tkinter.Toplevel(self.parent)
        self.dialog.title(field.name)
        

        
#        lframe=Tkinter.Frame(frame)
#        lframe.pack()
#        
#        recs=['{}={}'.format(k,v) for k,v in hole.info.iteritems()]
#        
#        for txt in recs:
#            Tkinter.Label(self.dialog, text=txt).pack()

#        Tkinter.Label(lframe, text='Setup #:').grid(row=0,column=0)


        self.keep_all = Tkinter.IntVar(value=int(field.keep_all))
        Tkinter.Checkbutton(self.dialog, text="Keep All",
                            variable=self.keep_all).pack()
        if field.obsdate:
            now=field.obsdate.strftime('%Y-%m-%d %H:%M:%S')
        else:
            now=datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        self.date_str=Tkinter.StringVar(value=now)
        Tkinter.Entry(self.dialog, validate='focusout', width=20,
                      invcmd=lambda:tkMessageBox.showerror('Bad Time',
                                                           'Y-m-d H:M:S'),
                      vcmd=self.vet_obsdate, textvariable=self.date_str).pack()
        
        
#        Tkinter.Button(self.dialog,text='Done',command=self.ok).pack()
#        item.grid(row=i,column=0)

        self.dialog.bind("<FocusOut>", self.defocusCallback)
        self.dialog.bind("<Destroy>", self.destroyCallback)

    def defocusCallback(self, event):
        pass
    
    def vet_obsdate(self):
        try:
            datetime.strptime(self.date_str.get(), '%Y-%m-%d %H:%M:%S')
            return True
        except ValueError:
            return False
    
    def destroyCallback(self, event):
        if self.save():
            self.dialog.destroy()

    def save(self):
        try:
            self.field.obsdate=datetime.strptime(self.date_str.get(),
                                                 '%Y-%m-%d %H:%M:%S')
        except ValueError:
            return False
        self.field.keep_all=bool(self.keep_all.get())
        return True

class HoleInfoDialog:
        
    def __init__(self, parent, canvas, holes):
        self.canvas=canvas
        self.parent=parent
        
        if len(holes) > 1:
            self.initializeSelection(holes)
        else:
            self.initializeSingle(holes[0])
            
    def initializeSelection(self, holes):
        
        self.dialog=Tkinter.Toplevel(self.parent)
        self.dialog.bind("<FocusOut>", self.defocusCallback)
        self.dialog.bind("<Destroy>", self.destroyCallback)
        
        for i,hole in enumerate(holes):
            
            #self.canvas.itemconfigure('.'+id, state=Tkinter.DISABLED)

            lbl_str=' '.join(['{}={}'.format(k,v)
                              for k,v in hole.info.iteritems()])

            def cmd():
                self.close()
                self.initializeSingle(hole)
            item=Tkinter.Label(self.dialog, text=lbl_str)
            item.grid(row=i,column=0)
            item=Tkinter.Button(self.dialog,text='Select', command=cmd)
            item.grid(row=i,column=1)

    def initializeSingle(self, hole):

        #self.canvas.itemconfigure('.'+holeID,state=Tkinter.DISABLED)
        self.dialog=Tkinter.Toplevel(self.parent)
        self.dialog.bind("<FocusOut>", self.defocusCallback)
        self.dialog.bind("<Destroy>", self.destroyCallback)
        
        
        recs=['{}={}'.format(k,v) for k,v in hole.info.iteritems()]
        
        for txt in recs:
            Tkinter.Label(self.dialog, text=txt).pack()
        
        Tkinter.Button(self.dialog,text='Done',command=self.ok).pack()

    def defocusCallback(self, event):
        pass
        #self.ok()
    
    def ok(self):
        self.save()
        self.close()
    
    def destroyCallback(self, event):
        pass
        #self.resetHoles()

    def save(self):
        pass    
    
    def close(self):
        self.dialog.destroy()
        
    def resetHoles(self):
        if isinstance(self.holeID, str):
            self.canvas.itemconfig('.'+self.holeID,state=Tkinter.NORMAL)
        else:
            for id in self.holeID:
                self.canvas.itemconfig('.'+id,state=Tkinter.NORMAL)



class App(Tkinter.Tk):
    def __init__(self, parent):
        Tkinter.Tk.__init__(self, parent)
        self.parent = parent
        self.initialize()

    def initialize(self):
        
        self.manager=fieldmanager.Manager()
        
        #Basic window stuff
        swid=120
        bhei=55
        whei=735
        chei=whei-bhei
        wwid=chei+swid
        self.geometry("%ix%i"%(wwid,whei))
        self.title("Foo Bar")
        
        #The sidebar
        frame = Tkinter.Frame(self, width=swid, bd=0, bg=None)#None)
        frame.place(x=0,y=0)

        #Info display
        frame2 = Tkinter.Frame(self, height=bhei, bd=0, bg=None)#None)
        frame2.place(x=0,y=whei-45-1)

        #The canvas for drawing the plate        
        self.canvas=BetterCanvas.BetterCanvas(self, chei, chei,
                                              1.01*PLATE_RADIUS,
                                              1.01*PLATE_RADIUS,
                                              bg='White')
        self.canvas.place(x=swid,y=0)
        self.canvas.bind("<Button-1>", self.canvasclick)

        #Buttons
        Tkinter.Button(frame, text="Load Fields",
                       command=self.load_fields).pack()
        Tkinter.Button(frame, text="Reset",
                       command=self.reset).pack()
        Tkinter.Button(frame, text="Select Fields",
                       command=self.field_info_window).pack()
        Tkinter.Button(frame, text="Make Plate",
                       command=self.make_plate).pack()
        Tkinter.Button(frame, text="Toggle Conflicts",
                       command=self.toggle_conflicts).pack()
        self.show_conflicts=True

        #Info output
        self.info_str=Tkinter.StringVar(value='Red: 000  Blue: 000  Total: 0000')
        Tkinter.Label(frame2, textvariable=self.info_str).pack(anchor='w')
    
    def status_string(self):
        return 'Foobar'
    
    def reset(self):
        self.manager.reset()
        self.show()
    
    def canvasclick(self, event):
        #Get holes that are within a few pixels of the mouse position
        region=2
        items=self.canvas.find_overlapping(event.x-region,
                                           event.y-region,
                                           event.x+region,
                                           event.y+region)
        items=filter(lambda a: 'hole' in self.canvas.gettags(a), items)
            
        if items:
            holeIDs=tuple([tag[1:] for i in items
                                   for tag in self.canvas.gettags(i)
                                   if tag[-1].isdigit()])
            holes=self.manager.get_holes(holeIDs)
            HoleInfoDialog(self.parent, self.canvas, holes)

    def toggle_conflicts(self):
        self.show_conflicts=not self.show_conflicts
        self.show()

    def show(self):
        self.canvas.clear()
        self.info_str.set(self.status_string())
        self.manager.draw(self.canvas, show_conflicts=self.show_conflicts)

    def load_fields(self):
        file=tkFileDialog.askdirectory(initialdir='./')
        file=os.path.normpath(file)
        print file
        if file:
            self.manager.load(file)

    def field_info_window(self):
    
        new=Tkinter.Toplevel(self)
        
        cols=('RA', 'Dec', 'nT+S', 'nConflict')
        self.tree = tree = ttk.Treeview(new, columns=cols)
        tree.heading('#0',text='Name')
        for c in cols:
            tree.heading(c,text=c)
        
        for f in self.manager.fields:
            tree.insert('', 'end', f.name, text=f.name, tags=(),
                        values=(f.sh.ra.sexstr, f.sh.dec.sexstr,
                                len(f.targets)+len(f.skys),f.n_conflicts))
        tree.bind('<Button-2>', self.field_settings)
        tree.bind('<ButtonRelease-1>', func=self.select_fields)
        tree.pack()
        tree.focus()
    #    tree.tag_configure('ttk', background='yellow')
    #    tree.tag_bind('ttk', '<1>', itemClicked); # the item clicked can be found via tree.focus()

    def choose_fields(self):
        self.field_info_window(self.select_fields)

    def field_settings(self, event):
        name=event.widget.identify_row(event.y)
        field=self.manager.get_field(name)
        w=FieldSettingsDialog(self, field)
        self.wait_window(w.dialog)
    
    def select_fields(self, event):
        log.info('Selecting {}'.format(event.widget.selection()))
        try:
            self.manager.select_fields(event.widget.selection())
        except ConstraintError as e:
            tkMessageBox.showerror('Incompatible Fields', str(e))
            
        #update treview nconflict column
        for f in self.manager.selected_fields:
            self.tree.set(f.name, 'nConflict', f.n_conflicts)
        self.show()

    def make_plate(self):
        w=PopupWindow(self, get=str, query="Plate Name?")
        self.wait_window(w.top)
        self.manager.save_selected_as_plate(w.value)
        self.canvas.postscript(file=w.value+'.eps', colormode='color')


class PopupWindow(object):
    def __init__(self, master, get=str, query="No query specified"):
        top=self.top=Tkinter.Toplevel(master)
        self.l=Tkinter.Label(top,text=query)
        self.l.pack()
        if get == str:
            self.e=Tkinter.Entry(top)
            self.e.pack()
            self.value=''
        self.b=Tkinter.Button(top,text='Ok',command=self.cleanup)
        self.b.pack()

    def cleanup(self):
        self.value=self.e.get()
        self.top.destroy()


if __name__ == "__main__":
    log.info('Starting...')
    app = App(None)
    app.title('Hole Mapper')
    app.mainloop()