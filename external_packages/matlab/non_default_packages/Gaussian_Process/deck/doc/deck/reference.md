
# Module reference

Root folder structure with submodules:
```
+dk/
├── +bsx        singleton expansion routines
├── +cmap       colormaps
├── +color      color definitions
├── +ds         data-structures
├── +env        environment variables
├── +fig        figure management
├── +fs         filesystem utils
├── +is         assertion helpers
├── +json       JSON reader/writer
├── +logger     custom logging
├── +num        numerics helpers
├── +obj        object definitions
├── +priv       internal utils
├── +screen     display management
├── +str        string utils
├── +struct     structure utils
├── +test       testing routines
├── +time       time & date utils
├── +ui         UI helpers
├── +util       public utils
└── +widget     UI components
```

## General utilities

Documentation is [here](deck/util/index).

```
+dk/
    bytesize.m          getelem.m           load.m              torow.m             
    chkmver.m           getopt.m            notify.m            tostr.m             
    compare.m           gridfit.m           save.m              trywait.m           
    countunique.m       grouplabel.m        savehd.m            
    formatmv.m          groupunique.m       tocol.m             

+util/
    array2cpp.m         bytefmt.m           func_ismember.m     path2name.m         
    array2str.m         email.m             func_neq.m          timeit.m            
    bool2yn.m           func_eq.m           numcores.m          vec2str.m      
```

## Functional programming

Documentation is [here](deck/fprog/index).

```
+dk/
    call.m              forward.m           mapfun.m            reduce.m            
    deal.m              kvfun.m             pass.m              reverse.m 

+bsx/
    add.m               geq.m               lt.m                sub.m               
    and.m               gt.m                mul.m               
    dot.m               ldiv.m              or.m                
    eq.m                leq.m               rdiv.m 

```

## Struct, cell, string

Documentation is [here](deck/ctn/index).

```
+dk/
    c2s.m               s2c.m               unwrap.m            wrap.m              

+str/
    Template.m          join.m              singlespaces.m      xrem.m              
    capfirst.m          lstrip.m            startswith.m        xrep.m              
    capwords.m          numbers.m           strip.m             xset.m              
    endswith.m          rstrip.m            to_substruct.m      

+struct/
    array.m             filter.m            merge.m             to_cell.m           
    assign.m            from_cell.m         rem.m               to_table.m          
    disp.m              get.m               repeat.m            to_vars.m           
    extract.m           grid.m              restrict.m          values.m            
    fields.m            make.m              set.m 
```

## Assertion, logging

Documentation is [here](deck/log/index).

```
+dk/
    assert.m            disp.m              log.m               verb.m              
    debug.m             info.m              reject.m            warn.m              

+is/
    boolean.m           integer.m           rgb.m               string.m            
    empty.m             matrix.m            square.m            struct.m            
    even.m              number.m            squareneg.m         vector.m            
    fhandle.m           odd.m               squarepos.m         

+logger/
    Logger.m            del.m               list.m              
    default.m           get.m 
```

## System, path, file

Documentation is [here](deck/sys/index).

```
+dk/
    here.m              path.m              

+env/
    AbstractManager.m   SystemPath.m        filtpath.m          is64bits.m          
    Library.m           clearpath.m         home.m              ld_name.m           
    Path.m              computername.m      hostname.m          path_flag.m         
    Runtime.m           desktop.m           is32bits.m          require.m           

+fs/
    File.m              exist.m             ls.m                safename.m          
    InputFile.m         gets.m              lsdir.m             search.m            
    OutputFile.m        isavail.m           lsext.m             tempname.m          
    basename.m          isdir.m             lsfiles.m           walk.m              
    chkdir.m            isfile.m            match.m             
    chkfile.m           islink.m            puts.m              
    dirname.m           iterlines.m         realpath.m
```

## Figure, colour, UI

Documentation is [here](deck/ui/index).

```
+cmap/
    act.m               interp.m            rdb2.m              wjet.m              
    bgr.m               jet.m               rwb.m               
    cold.m              jh.m                rwb2.m              
    hot.m               matlab.m            show.m              

+color/
    hex2rgb.m           palette.m           sepia.m             tone.m              
    jh.m                proc.m              shade.m             
    mix.m               rgb2hex.m           tint.m              

+fig/
    export.m            new.m               recenter.m          size.m              
    maximise.m          position.m          rescale.m           tile.m              
    movetoscreen.m      print.m             resize.m            

+screen/
    centre.m            height.m            size.m              
    count.m             info.m              width.m             

+ui/
    alphashape.m        datamatrix.m        mesh.m              sphere.m            
    area.m              disk.m              plot.m              surface.m           
    axes2image.m        face2vertex.m       prctile.m           title.m             
    axesgrid.m          fill.m              quiver.m            triangulation.m     
    circle.m            ginput.m            ring.m              violin.m            
    colorbar.m          ginput_surf.m       scatter.m           wheel.m             
    convhull.m          lights.m            sdplot.m            

+widget/
    FrameStack.m        MultiTab.m          SelectBox.m         menu_3Dview.m       
    ImageBox.m          PropertyEditor.m    Slider.m            menu_ginput.m
```

## Numerics

Documentation is [here](deck/num/index).

```
+num/
    between.m           filter.m            modeq.m             randhex.m           
    ceil.m              floor.m             msdeq.m             randperm.m          
    clamp.m             infreplace.m        nanreplace.m        range.m             
    digits.m            isperm.m            nextint.m           round.m             
    divmod.m            magnitude.m         radinv.m            trunc.m 
```

## Time and date

Documentation is [here](deck/time/index).

```
+time/
    Timer.m             duration2string.m   seconds2duration.m  
    datestr.m           sec2str.m 
```

## Other

Documentation for: 
 - Data-structures is [here](deck/adv/ds);
 - Function arguments is [here](deck/adv/arg);
 - JSON parsing is [here](deck/adv/json).

```
+ds/
    BinaryTree.m        DataArray.m         Mapping.m           SplitTree.m         
    Cell.m              LinkedList.m        Matrix.m            Tree.m              

+obj/
    DataStore.m         List.m              kwArgs.m            
    Grid.m              Reference.m         

+json/
    Array.m             Object.m            read.m              
    Caret.m             decode.m            typeid.m            
    Format.m            encode.m            write.m
```

