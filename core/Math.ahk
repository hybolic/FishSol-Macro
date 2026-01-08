;@region Vector2D
class Vector2D
{
    /**
     * @description Basic Vector2D holder
     * @module Vector2D
     * @param {Number} [X]
     * @param {Number} [Y]
     * @class Vector2D
     * @classdesc Basic Vector2D holder
     * @constructor
     */

    __New(X:=0, Y:=0)
    {
        this.X := X
        this.Y := Y
    }


    /**
    * @member {Number} 
    */
    X := 0
    
    /** @member {Number} 
    */
    Y := 0

    /**
     * @description Adds to Vector2D's X and Y position then returns itself
     * @param {Number} X
     * @param {Number} Y
     * @function
     */
    Add(X,Y)
    {
        this.X += X
        this.Y += Y
        return this
    }

    /**
     * @description subtracts from Vector2D's X and Y position then returns itself
     * @param {Number} X
     * @param {Number} Y
     * @function
     */
    Subtract(X,Y)
    {
        this.X -= X
        this.Y -= Y
        return this
    }

    /**
     * @description multiplies the Vector2D's X and Y position then returns itself
     * @param {Number} X
     * @param {Number} Y
     * @function
     */
    Multiply(X,Y)
    {
        this.X *= X
        this.Y *= Y
        return this
    }

    /**
     * @description sets the Vector2D's X and Y position then returns itself
     * @param {Number} X
     * @param {Number} Y
     * @function
     */
    Set(X,Y)
    {
        this.X := X
        this.Y := Y
        return this
    }
    
    /** @ignore 
    */
    isVector2D()
    {
        return true
    }
    
}

;@endregion Vector2D
;@region Rectangle2

class Rectangle2
{

    /**
     * @class Rectangle2
     * @classdesc Basic Rectangle2 holder
     * @param {Vector2D} [Pos]
     * @param {Number} [Wid]
     * @param {Number} [Hei]
     * @constructor
     */
    __New(Pos, Wid, Hei)
    {
        this.Position := Pos
        this.Width    := Wid
        this.Height   := Hei
    }


    ;@todo combine both __New
     ; __New(X, Y, Wid, Hei)
     ; {
     ;     this.Position := new Vector2D(X,Y)
     ;     this.Width    := Wid
     ;     this.Height   := Hei
    ; }

    /** @member {Vector2D} 
    */
    Position := ""
    /** @member {Number} 
    */
    Width    := 0
    /** @member {Number} 
    */
    Height   := 0

    /** @ignore 
    */
    isRectangle2()
    {
        return true
    }
    
    /**
     * @description set the X/Y Position of the Rectangle2
     * @param {Number} X
     * @param {Number} Y
     * @returns {Rectangle2}
     */
    SetPosition(X,Y)
    {
        this.Position.Set(X,Y)
        return this
    }

    /**
     * @description Offsets the X/Y Position of the Rectangle2
     * @param {(Number|Rectangle2|Vector2D)} X Number or Vector2D/Rectangle2
     * @param {?Number} Y
     * @returns {Rectangle2}
     */
    Offset(X,Y:="")
    {
        if parent.isVector2D()
            this.Position.Add(parent.X, parent.Y)
        else if parent.isRectangle2()
            this.Position.Add(parent.Position.X, parent.Position.Y)
        else
            this.Position.Add(X, Y)
        return this
    }

    /**
     * @description Scales the Rectangle2
     * @param {...Number} scale either overall scale or W/H
     * @returns {Rectangle2}
     */
    Scale(scale*)
    {
        scale_1 := MathStuff.NumOrDefault(scale[1], 1)
        this.Width  *= scale_1
        this.Height *= MathStuff.NumOrDefault(scale[2], scale_1)
        return this
    }

    ;@region Rectangle2.FLAGS
    /**
     * @description Byte location index
     * @fixed {Number}
    */
    static ByteLoc_FLAG_VERTICLE_SCALING    := 1

    /**
     * @fixed {Flag}
    */
    static FLAG_VERTICLE_SCALING            := 0x1 << (Rectangle2.ByteLoc_FLAG_VERTICLE_SCALING - 1)

    
    /**
     * @description Byte location index
     * @fixed {Number}
    */
    static ByteLoc_FLAG_HORIZONTAL_SCALING  := 2

    /**
     * @fixed {Flag}
    */
    static FLAG_HORIZONTAL_SCALING          := 0x1 << (Rectangle2.ByteLoc_FLAG_HORIZONTAL_SCALING - 1)

    /**
     * @type {Flag}
     * @description at the moment corners are just assigning it as the two bits from {@link Rectangle2.FLAG_VERTICLE_SCALING|FLAG_VERTICLE_SCALING} and {@link Rectangle2.FLAG_HORIZONTAL_SCALING|FLAG_HORIZONTAL_SCALING}
     * @fixed {Flag}
    */
    static FLAG_CORNERS                     := Rectangle2.FLAG_VERTICLE_SCALING + Rectangle2.FLAG_HORIZONTAL_SCALING

    /**
     * @description Byte location index
     * @fixed {Number}
    */
    static ByteLoc_FLAG_CENTERING_VERT      := 3

    /**
     * @fixed {Flag}
    */
    static FLAG_CENTERING_VERT         := 0x1 << (Rectangle2.ByteLoc_FLAG_CENTERING_VERT - 1)

    /**
     * @description Byte location index
     * @fixed {Number}
    */
    static ByteLoc_FLAG_Use_MIN_OR_MAX      := 4

    /**
     * @fixed {Flag}
    */
    static FLAG_Use_MIN_OR_MAX              := 0x1 << (Rectangle2.ByteLoc_FLAG_Use_MIN_OR_MAX - 1)

    /**
     * @description Byte location index
     * @fixed {Number}
    */
    static ByteLoc_FLAG_IGNORE_SCALING      := 8

    /**
     * @fixed {Flag}
    */
    static FLAG_IGNORE_SCALING              := 0x1 << (Rectangle2.ByteLoc_FLAG_IGNORE_SCALING - 1)
    
    /** @typedef Flags
     * @see {@link Rectangle2.FLAG_VERTICLE_SCALING}
     * @see {@link Rectangle2.FLAG_HORIZONTAL_SCALING}
     * @see {@link Rectangle2.FLAG_CORNERS}
     * @see {@link Rectangle2.FLAG_Use_MIN_OR_MAX}
     * @see {@link Rectangle2.FLAG_IGNORE_SCALING}
     */
    ;@endregion Rectangle2.FLAGS

    /**
     * @description NO_DESCRIPTION
     * @param {Rectangle2} parent the parent of the scale
     * @param {(Rectangle2|Vector2D|Number[])} bounds bounds to constrain scale to
     * @param {Flag} flags {@link Flags|Valid Flags}
     * @returns {Rectangle2}
     */
    RescaleAndOffset(parent, bounds, flags=0)
    {
        ;scale to Width or Height
        VerticleScaling      := MathStuffs.getByte(flags,Rectangle2.ByteLoc_FLAG_VERTICLE_SCALING)
        HorizontalScaling    := MathStuffs.getByte(flags,Rectangle2.ByteLoc_FLAG_HORIZONTAL_SCALING)
        
        ;if top two aren't set use this variable to switch between either Min or Max
        ScaleUses_MinORMax := MathStuffs.getByte(flags,Rectangle2.ByteLoc_FLAG_Use_MIN_OR_MAX)
        
        ;Forces the scaling to be 1x
        ignoreScale     := MathStuffs.getByte(flags,Rectangle2.ByteLoc_FLAG_IGNORE_SCALING)

        ;defautls
        bounds_PosY := 0
        bounds_PosX := 0
        Scale := 1
        
        ;this checks what type of variable <bounds> is and does something accordingly
        if bounds.isRectangle2() ;if it was a Rectangle2 use all variables
        {
            bounds_PosX := bounds.Position.X
            bounds_PosY := bounds.Position.Y
            bounds_Width := bounds.W
            bounds_Height := bounds.H
        }
        Else if bounds.isVector2D() ;if it was a point treat it as the width and height
        {
            bounds_Width := bounds.X
            bounds_Height := bounds.Y
        }
        Else if bounds.Length() = 4 ; same as Rectangle2 just we do Pop to grab the elements in reverse order incase its not indexed correctly
        {                           ; [3:num1, 8:num2, 33:num3, 192:num4] we just grab the numbers backwards instead of indexing for this reason
            bounds_Height := bounds.Pop()
            bounds_Width := bounds.Pop()
            bounds_PosY := bounds.Pop()
            bounds_PosX := bounds.Pop()
        }
        Else if bounds.Length() = 2 ;same as above just shorter
        {
            bounds_Height := bounds.Pop()
            bounds_Width := bounds.Pop()
        }
        Else if bounds is Number ;if its just a single number we just assume its a square for bounds
        {
            bounds_Height := bounds
            bounds_Width := bounds
        }
        Else ;else something has gone terribly wrong
        {
            throw { What: 1, File: A_LineFile, Line: A_LineNumber, Message:"bounds variable is Malformed, it needs to either be a number, vector or Rectangle2!" }
        }

        if not ignoreScale
        {
            if HorizontalScaling
                Scale  := parent.W / bounds_Width
            Else if VerticleScaling
                Scale  := parent.H / bounds_Height
            Else if ScaleUses_MinORMax
                Scale := Min(parent.W / bounds_Width, parent.H / bounds_Height)
            Else
                Scale := Max(parent.W / bounds_Width, parent.H / bounds_Height)
        }

        P_PosX := parent.Position.X
        P_PosX += bounds_PosX

        P_PosY := parent.Position.Y
        P_PosY += bounds_PosY

        P_Width := parent.W
        P_Height := parent.H
        
        if this.HasCompensation()
        {
            this.getCompensation(Scale, THIS_PosX, THIS_PosY, P_Width, P_Height)
        }
        Else
        {
            THIS_PosX := this.Position.X * Scale
            THIS_PosY := this.Position.Y * Scale
        }

        Corner := flags & Rectangle2.FLAG_CORNERS
        
        switch %Corner%
        {
            case 1:          ;0 1 TopRight anchor
                return this.SetPosition(P_PosX + P_Width - THIS_PosX, P_PosY + THIS_PosY).Scale(Scale)
            case 2:          ;1 0 BotLeft anchor
                return this.SetPosition(P_PosX + THIS_PosX, P_PosY + P_Height - THIS_PosY).Scale(Scale)
            case 3:          ;1 1 BotRight anchor
                return this.SetPosition(P_PosX + P_Width - THIS_PosX, P_PosY + P_Height - THIS_PosY).Scale(Scale)
            case 0, Default: ;0 0 TopLeft anchor or just failover by default if something goes wrong
                return this.SetPosition(P_PosX + THIS_PosX, P_PosY + THIS_PosY).Scale(Scale)
        }
    }
    

    /**
     * @description Returns True if instance of this class has {@link OffsetCompensation} attatched
     * @returns {Boolean}
     */
    HasCompensation()
    {
        Return &this._OffsetCompensation != &this.UNUSED_VARIABLE
    }

    /**
     * @description Sets the {@link OffsetCompensation|compensation}
     * @param {(number|OffsetCompensation)} lowX
     * @param {?number} lowY
     * @param {?number} highX
     * @param {?number} highY
     * @returns {Rectangle2}
     */
    SetOffsetCompensation(lowX, lowY:="", highX:="", highY:="")
    {
        if lowX.isOffsetCompensation()
            this._OffsetCompensation := lowX
        ly := MathStuffs.NumOrDefault(lowY, lowX)
        hx := MathStuffs.NumOrDefault(highX, lowX)
        hy := MathStuffs.NumOrDefault(highY, lowX)
        this._OffsetCompensation := new OffsetCompensation(lowX, ly, hx, hy)
        return this
    }

    /**
     * @description returns a compensated offset between High and Low by amount
     * @param {Float} Amount
     * @param {Number} byrefX
     * @param {Number} byrefY
     * @param {?Number} scaleX
     * @param {?Number} scaleY
     * @param {?Number} offX
     * @param {?Number} offY
     * @returns {Vector2D}
     */
    getCompensation(Amount, byref X, byref Y, scaleX:="", scaleY:="", offX := "", offY := "")
    {
        vect := this._OffsetCompensation.getCompensation(Amount, scaleX, scaleY)
        X += vect.X
        Y += vect.Y
        return vect
    }
}

;@endregion Rectangle2
;@region OffsetCompensation

class OffsetCompensation
{
    /** @ignore */
    Low  := ""
    /** @ignore */
    High := ""
    /** @ignore */
    StoredReturnVector := ""
    /** @ignore */
    isOffsetCompensation()
    {
        return true
    }

    /**
     * Basic OffsetCompensation holder
     * @class OffsetCompensation
     * @classdesc Basic OffsetCompensation holder
     * @description makes a new instance of OffsetCompensation<br/><pre>         - </pre>please either use 4 numbers or 2 Vectors
     * @param {(Number|Vector2D)} var1 - both var1 and var2 must be of same TYPE
     * @param {(Number|Vector2D)} var2 - both var1 and var2 must be of same TYPE
     * @param {?Number} highX
     * @param {?Number} highY
     * @constructor
     */

    __New(var1, var2, highX := "", highY := "")
    {
        if var1.isVector2D() and var2.isVector2D()
        {
            this.Low := var1
            this.High := var2
        }
        else
        {
            this.Low  := new Vector2D( var1,  var2)
            this.High := new Vector2D(highX, highY)
        }
        this.StoredReturnVector := new Vector2D(0,0)
    }


    ;returns a compensated offset between High and Low by amount
    /**
     * @description returns a compensated offset {@link Vector2D|Vector} between High and Low by amount of this offset
     * @param {Number} Amount
     * @param {Number} [scaleX]
     * @param {Number} [scaleY]
     * @param {Number} [offX]
     * @param {Number} [offY]
     * @returns {Vector2D}
     */
    getCompensation(Amount, scaleX:="", scaleY:="", offX := "", offY := "")
    {
        return MathStuffs.Lerp2D(this.Low, this.High, Amount, this.StoredReturnVector, scaleX, scaleY, offX, offY)
    }
    
    /**
     * @description Swaps the X values between both High and Low offsets
     * @returns {OffsetCompensation}
     */
    SwapX()
    {
        tX := this.High.X
        this.High.X := this.Low.X
        this.Low.X := tX
        return this
    }
    
    /**
     * @description Swaps the Y values between both High and Low offsets
     * @returns {OffsetCompensation}
     */
    SwapY()
    {
        tY := this.High.Y
        this.High.Y := this.Low.Y
        this.Low.Y := tY
        return this
    }
    
    /**
     * @description Swaps the X<>Y values in both High and Low offsets
     * @returns {OffsetCompensation}
     */
    SwapXY()
    {
        t1Y := this.Low.Y
        this.Low.Y := this.Low.X
        this.Low.X := t1Y
        
        t2Y := this.High.Y
        this.High.Y := this.High.X
        this.High.X := t2Y

        return this
    }

    /**
     * @description Swaps the High and Low offsets
     * @returns {OffsetCompensation}
     */
    SwapHighLow()
    {
        t := this.High
        this.High := this.Low
        this.Low := t
        return this
    }

}

;@endregion OffsetCompensation
;@region MathStuffs

/**
 * @name MathStuffs
 * @class MathStuffs
 * @classdesc hold some Maths stuff
 * @hideconstructor
 */
class MathStuffs
{
    ; Linearly interpolates between two points given the <amount>
    ;
    /**
     * @description Linearly interpolates between two {@link Number} given the amount returning a new point as the offset
     * @static
     * @param {Vector2D} Vector_One
     * @param {Vector2D} Vector_Two
     * @param {(Number)} Amount
     * @returns {Number}
     */
    Lerp(Vector_One, Vector_Two, Amount)
    {
        return Vector_One + ((Vector_Two - Vector_One) * Amount)
    }
    
    /**
     * @description Linearly interpolates between two {@link Vector2D|Points}  given the amount returns a {@link Vector2D|new vector} or referenced vector with the offset
     * @static
     * @param {Vector2D} Vector_One 
     * @param {Vector2D} Vector_Two
     * @param {Number} Amount
     * @param {Vector2D} [byref=""] {@link Vector2D|byref} will return via Byref if set
     * @param {...Number} [options] - eg. scaleX scaleY offsetX offsetY
     * @return {Vector2D} [Byref ret]
     */
    Lerp2D(Vector_One, Vector_Two, Amount, byref ret:="", params*) ;replace & with byref for export only because syntax during documentation
    {

        if (ret := "")
            ret := new Vector2D()

        scaleX := MathStuffs.NumOrDefault(params[1])    ;scaleX set to first param, else set to 1
        scaleY := MathStuffs.NumOrDefault(params[2], w) ;assume square if only one variable given
        offX   := MathStuffs.NumOrDefault(params[3], 0) ;default 0 offsetX
        offY   := MathStuffs.NumOrDefault(params[4], 0) ;default 0 offsetY
        
        return ret.Set(offX + MathStuffs.Lerp(scaleX * Vector_One.X, scaleX * Vector_Two.X, Amount)
                     , offY + MathStuffs.Lerp(scaleY * Vector_One.Y, scaleY * Vector_Two.Y, Amount))
    }

    /**
     * returns the number or default if one is not given
     * @static
     * @param {Number} [Varible=""] - Input Varible 
     * @param {Number} [Default=1] - return if Varible is invalid
     * @returns {Number}
     */
    NumOrDefault(Var, Default := 1)
    {
        if Default is not Number
            throw { What: 1, File: A_LineFile, Line: A_LineNumber, Message: "Default is not a number!" }
        
        if Var is not Number
            return Default
        return Var
    }

    ;returns the bit (true or false) at the <index> in variable <Var>
    /**
     * Get the indexed {@link Bit|Bit} from an {@link Number}
     * @static
     * @param {Number} Var
     * @param {Integer} index
     * @returns {Boolean}
     */
    GetByte(Var, index)
    {
        ;if we've already computed this number before jus return the byte
        if MathStuffs.stored_getBytes.HasKey(Var)
            return MathStuffs.stored_getBytes[Var][index]
        ;otherwise compute the whole number and then return the byte
        Else
            return this.GetBytes(Var)[index]
    }
    /**
     * @description lookup reference array for later use incase we overuse the getBytes or GetByte function
     * @static
     * @private
     */
    static stored_getBytes := []

    /**
     * gets the {@link Bit|bits} associated with {@link Number} variable given
     * @static
     * @param {Number} Var
     * @returns {Bit[]}
     */
    GetBytes(Var)
    {
        if var is not Number
        {
            throw Exception("WHY!?")
            Return
        }

        ;if we've already done this number before just return its value
        if MathStuffs.stored_getBytes.HasKey(Var)
            return MathStuffs.stored_getBytes[Var].Clone()

        ;otherwise compute it
        array := []
        loop % strlen(Var)
            array[A_Index] := (Var & (0x1 << (A_Index - 1))) >> (A_Index - 1)
        ;store it
        MathStuffs.stored_getBytes[Var] := array

        return array.Clone()
    }
    
    ;Returns a Random Hex string of <Length>
    /**
     * Returns a Random {@link https://en.wikipedia.org/wiki/Hexadecimal|Hexdecimal} string of a given length
     * @static
     * @param {Number} length
     * @returns {String} a string representation of a hex value of length
     */
    RandomHexdecimal(length)
    {
        len := max(length,1)
        loop % len
            HEX .= "|0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F"
        Sort, HEX, Random D|
        HEX := SubStr(StrReplace(HEX, "|"), 1, len)
        return "0x" . HEX
    }

    /**
     * quick {@link https://en.wikipedia.org/wiki/Pi|pi}, for when its needed
     * @static
     * @returns {Number} 3.141592653589793
     */
    Pi()
    {
        return 3.141592653589793
    }
    
    /**
     * quickly {@link https://www.autohotkey.com/docs/v1/Variables.htm#bitwise|Bitwise} Or's all values given
     * @static
     * @param {Number} values...
     * @returns {Number}
     */
    LinearOr(values*)
    {
        output := 0x0
        for _, value in values
            output := output | value
        return output
    }
}

;@endregion MathStuffs