/* ----------------------------------------------------
-- Hemoeco Renta (2025)
--
-- FUnción para calcula fecha (datetime) a partir de un
-- entero untilizado por Score (Clarion)
 ---------------------------------------------------- */
 
 CREATE Function [dbo].[Fecha](@Fecha Int) Returns dateTime
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

-- -- Tests
-- -- To run test, just uncomment 
-- print Concat('Fecha(0) = ', dbo.Fecha(0)) -- null
-- print Concat('Fecha(80723) = ', dbo.Fecha(80723)) -- 2022-01-01 00:00:00.000