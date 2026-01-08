;attempting to unify everything found in Rectangle.ahk here
;#Include "\core\Math.ahk"
class Point2
{
    __New(Pos)
    {
        this.Pos := Pos
        this.OriginalX := Pos.X
        this.OriginalY := Pos.Y
    }
    
    MouseMoveAndClick(WhichButton, speed)
    {
        this.MouseMove(speed)
        this.Click(WhichButton)
    }
    
    MouseMoveAndClickWithSleep(WhichButton, speed, Sleep1, Sleep2_:="")
    {
        local Sleep2
        
        if &Sleep2_ = &this.unused
            Sleep2 := Sleep1
        Else
            Sleep2 := Sleep2_

        this.MouseMove(speed)
        
        Log.Low_Info("Sleep " Sleep1)
        sleep %Sleep1%
        
        this.Click(WhichButton)
        
        Log.Low_Info("Sleep " Sleep2)
        sleep %Sleep2%
    }

    MouseMove(speed)
    {
        Log.Low_Info("MouseMove @" this.Pos.X ":" this.Pos.Y)
        
        if Debugger.DoMouseMove
            MouseMove, % this.Pos.X, % this.Pos.Y, %speed%
    }

    Click(WhichButton)
    {
        if Debugger.DoMouseClick
            MouseClick, %WhichButton%

        Log.Low_Info("MouseClick " WhichButton)
    }

    PixelSeachPoint2(color, variation, byref outX := "", byref outY := "")
    {
        return this.PixelSeach(color, variation, outX, outY)
    }

    PixelSeach(color, variation, byref outX := "", byref outY := "")
    {
        global

        Log.Low_Info("PixelSearch @" this.Pos.X ":" this.Pos.Y)
        
        PixelSearch, x, y, % this.Pos.X, % this.Pos.Y, % this.Pos.X, % this.Pos.Y, % color , 3, Fast RGB
        
        outX := x
        outY := y
        
        return ErrorLevel
    }

    PixelGetColor(byref out)
    {
        global

        Log.Low_Info("PixelGetColor @" this.Pos.X ":" this.Pos.Y)
        
        PixelGetColor, var_out, % this.Pos.X, % this.Pos.Y, RGB
        out := var_out
        
        return ErrorLevel
    }
}

class PixelSeach
{
    __New(Pos, Wid, Hei)
    {
        this.rect := new Rectangle(Pos, Wid, Hei)
        this.OriginalX := Pos.X
        this.OriginalY := Pos.Y
        this.OriginalWidth := Wid
        this.OriginalHeight := Hei
    }

    PixelSearch(byref outX, byref outY, color, vari := 3, mode := "")
    {
        global
        local X2, Y2, el
        X2 := this.rect.X + this.rect.Width
        Y2 := this.rect.Y + this.rect.Height
        
        PixelSearch, px, py, % this.rect.X, % this.rect.Y, %X2%, %Y2%, %color%, %vari%, (mode = "" ? Fast RGB : %mode%)
        el := ErrorLevel

        outX := px
        outY := py

        return el
    }
}