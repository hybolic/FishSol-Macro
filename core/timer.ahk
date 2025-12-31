
class WatchData
{
    __New(unnamed := "")
    {
        this.freq       := -1
        this.start_time := -1
        this.stop_time  := -1
        this.last_time  := -1
        return this
    }

    get_uSeconds()
    {
        return RTrim(((this.last_time / this.freq) * 1000000) . "0","0")
    }

    get_ms()
    {
        return RTrim(((this.last_time / this.freq) * 1000) . "0", "0")
    }

    get_Seconds()
    {
        out := this.last_time / this.freq . ""
        if instr(out, ".")
            out := RTrim(out . "0","0")
        return out
    }

    get_Raw()
    {
        out := this.last_time / this.freq + 0
        return out
    }

    get_Minutes()
    {
        return (this.last_time / this.freq) / 60
    }

    get_Hours()
    {
        return (this.last_time / this.freq) / 3600
    }
}

class StopWatch
{
    Data := ""
    __New(unnamed := "")
    {
        this.Data := new WatchData()
        return this
    }

    Start()
    {
        DllCall("QueryPerformanceFrequency", "Int64*", f)
        DllCall("QueryPerformanceCounter", "Int64*", s)
        this.Data.freq := f
        this.Data.start_time := s
        return this
    }

    Stop()
    {
        DllCall("QueryPerformanceCounter", "Int64*", st)
        this.Data.stop_time := st
        this.Data.last_time := (this.Data.stop_time - this.Data.start_time)
        return this
    }

    getTimeData()
    {
        return this.Data
    }
}

class Benchmark
{
    Make_FromMethod_NoRef(byref StopWatchData, method, params*)
    {
        return Benchmark.Make_FromMethod(StopWatchData, method, unset, unset, unset, unset, unset, params)
    }

    Make_FromMethod_1(byref StopWatchData, method, byref param1, params*)
    {
        return Benchmark.Make_FromMethod(StopWatchData, method, param1, unset, unset, unset, unset, params)
    }
    
    Make_FromMethod_2(byref StopWatchData, method, byref param1, byref param2, params*)
    {
        return Benchmark.Make_FromMethod(StopWatchData, method, param1, param2, unset, unset, unset, params)
    }
    
    Make_FromMethod_3(byref StopWatchData, method, byref param1, byref param2, byref param3, params*)
    {
        return Benchmark.Make_FromMethod(StopWatchData, method, param1, param2, param3, unset, unset, params)
    }
    
    Make_FromMethod_4(byref StopWatchData, method, byref param1, byref param2, byref param3, byref param4, params*)
    {
        return Benchmark.Make_FromMethod(StopWatchData, method, param1, param2, param3, param4, unset, params)
    }
    
    Make_FromMethod(byref StopWatchData := "", method := "", byref param1 := "", byref param2 := "", byref param3 := "", byref param4 := "", byref param5 := "", params*)
    {
        MAX_BYREF := 5

        if IsFunc(method)
            THE_FUNC := Func(method)
        Else
            return

        ; get total used paramaters
        CUR_BYREFS := 0
        PARAM_COUNT_ALL := params[1].Count()
        loop % MAX_BYREF
        {
            if (param%A_Index% != unset) and (StrLen(param%A_Index%) > 0 or IsObject(param%A_Index%))
            {
                PARAM_COUNT_ALL++
                CUR_BYREFS++
            }
        }

        ;get byref locations if any
        SET_VAR := 0
        OVERFLOW := []
        Index_OverFlow := 0
        loop % THE_FUNC.MaxParams + PARAM_COUNT_ALL
        {
            if (THE_FUNC.IsByRef(A_Index) = true) and (SET_VAR < CUR_BYREFS)
            {
                SET_VAR++
                SET_PARAM%SET_VAR% := param%SET_VAR%
            }
            Else
            {
                Index_OverFlow++
                if SET_VAR < %MAX_BYREF%
                {
                    SET_VAR++
                    SET_PARAM%SET_VAR% := params[1][Index_OverFlow]
                }
                Else
                    OVERFLOW[OVERFLOW.Count() + 1] := params[1][Index_OverFlow]
            }
        }
        
        ;make the watch
        STOP_WATCH := new StopWatch()

        ;set function to be as fast as possible
        PREV_BATCHLINES := A_BatchLines
        SetBatchLines, -1
        
        ;start the watch
        STOP_WATCH.Start()
        
        ;start the method
        switch THE_FUNC.MaxParams + PARAM_COUNT_ALL
        {
            case 0 : FUNC_RETURN_VALUE := %THE_FUNC%(OVERFLOW*)
            case 1 : FUNC_RETURN_VALUE := %THE_FUNC%(SET_PARAM1,OVERFLOW*)
            case 2 : FUNC_RETURN_VALUE := %THE_FUNC%(SET_PARAM1,SET_PARAM2,OVERFLOW*)
            case 3 : FUNC_RETURN_VALUE := %THE_FUNC%(SET_PARAM1,SET_PARAM2,SET_PARAM3,OVERFLOW*)
            case 4 : FUNC_RETURN_VALUE := %THE_FUNC%(SET_PARAM1,SET_PARAM2,SET_PARAM3,SET_PARAM4,OVERFLOW*)
            Default: FUNC_RETURN_VALUE := %THE_FUNC%(SET_PARAM1,SET_PARAM2,SET_PARAM3,SET_PARAM4,SET_PARAM5,OVERFLOW*)
        }
        
        ;stop the watch!
        STOP_WATCH.Stop()
        StopWatchData := STOP_WATCH.getTimeData()
        ;restore byref params
        SET_VAR := 0
        loop % THE_FUNC.MaxParams
        {
            if (THE_FUNC.IsByRef(A_Index) = true) and (SET_VAR < CUR_BYREFS)
            {
                SET_VAR++
                param%SET_VAR% := SET_PARAM%SET_VAR%
            }
        }
        
        ;restet batchlines speed
        SetBatchLines, %PREV_BATCHLINES%
        
        return FUNC_RETURN_VALUE
    }
}

JoinStrTestFunction(byref str, sep, params*) {
    output := str
    for index, param in params
        output .= sep . param
    str := "Oh Something happened to the byref!"
    return output
}