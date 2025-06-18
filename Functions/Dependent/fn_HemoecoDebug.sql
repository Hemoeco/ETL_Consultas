-- ***********************************************************
-- (c) 2025 Hemoeco
--
-- Auxiliar para depurar valores de SQL
-- ***********************************************************

-- -- Clean up
-- drop function debug.fn_HemoecoDebugIsEnabled
-- drop function debug.fn_HemoecoDebugVerboseStatus
-- drop proc [debug].[sp_SetHemoecoDebugStatus]
-- drop proc debug.sp_EnableHemoecoDebug
-- drop proc debug.sp_DisableHemoecoDebug

go

Create or alter function [debug].[fn_HemoecoDebugIsEnabled] ()
returns bit
AS
Begin
    declare @result bit;
    Select top 1 @result = IsEnenabled from Hemoeco_Debug
    if (@result is null)
        return 0;

    return @result;
End
GO

Grant Execute, view definition on debug.fn_HemoecoDebugIsEnabled to public;
go

-- request debug status
Create or alter function debug.fn_HemoecoDebugVerboseStatus()
    returns varchar(20)
as
begin
    declare @status varchar(max)
    select @status = case debug.fn_HemoecoDebugIsEnabled()
        when 1 then 'enabled'
        else 'disabled'
    end

    return @status
end
go

Grant Execute, view definition on debug.fn_HemoecoDebugVerboseStatus to public;
go

-- Enable/disable debug
Create or alter proc [debug].[sp_SetHemoecoDebugStatus]
    @newValue bit
AS
Begin
    if exists(Select top 1 IsEnenabled from Hemoeco_Debug)
        begin
            update Hemoeco_Debug set IsEnenabled = @newValue;
        end
    else
        insert into Hemoeco_Debug(IsEnenabled) values(@newValue);

    print 'Hemoeco debug is ' + debug.fn_HemoecoDebugVerboseStatus()
End
go
Grant Execute, view definition on [debug].[sp_SetHemoecoDebugStatus] to public;
go

-- Enable debug
Create or alter proc [debug].[sp_EnableHemoecoDebug]
AS
Begin
    exec [debug].[sp_SetHemoecoDebugStatus] @newValue = 1
End
GO

Grant Execute, view definition on debug.sp_EnableHemoecoDebug to public;
go

-- Disable debug
Create or alter proc [debug].[sp_DisableHemoecoDebug]
AS
Begin
    exec [debug].[sp_SetHemoecoDebugStatus] @newValue = 0
End
GO

Grant Execute, view definition on debug.sp_DisableHemoecoDebug to public;
go

--  -- test
-- print debug.fn_HemoecoDebugIsEnabled();
-- exec debug.sp_EnableHemoecoDebug
-- print debug.fn_HemoecoDebugVerboseStatus();
-- exec debug.sp_DisableHemoecoDebug
-- print debug.fn_HemoecoDebugVerboseStatus();
