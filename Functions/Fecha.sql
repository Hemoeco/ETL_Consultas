SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE or alter Function [dbo].[Fecha](@Fecha Int) Returns dateTime
   AS
    Begin
      Declare @FechaJul DateTime
      IF(@Fecha > 0) and (@Fecha <= 109576)
       Set @FechaJul = (Select DATEADD(day, @Fecha, convert(datetime, '12/28/1800', 101))) 
      ELSE 
       Set @FechaJul = Null
       Return @FechaJul       
    End 

GO

Grant Execute, view definition on dbo.Fecha to public;
