select*from sys.procedures
go
use Negocios

create proc usp_001
as
begin 
select*from Ventas.clientes
end
go

exec usp_001
go

select*from Ventas.paises
alter procedure usp_001
@idpais char(3)
as
begin
	select*from  Ventas.paises
	where Idpais=@idpais
end
go
exec usp_001 '001'
go
drop proc usp_001
go

alter procedure usp_001
@p_idpais  char(3)='001'
as
begin
 select*from Ventas.clientes where idpais=@p_idpais
end
go
exec usp_001

create proc usp_002
@p_fecha1 date,@p_fecha2 date
as
begin
	select*from Ventas.pedidoscabe where FechaPedido between @p_fecha1 and @p_fecha2
end
go
exec usp_002 '21/02/98','05/03/98'
alter proc usp_002
@p_f1 date, @p_f2 date
as 
begin
	begin try 
	 if @p_f1<@p_f2
		select*from Ventas.pedidoscabe
		where FechaPedido between @p_f1 and @p_f2
	else
		raiserror ('error la primera fecha es mayot que la segunda',16,1)
	end try
	begin catch
		print error_message()
	end catch
end
go 
exec usp_002  '21/01/99','05/03/99'

select*from Ventas.pedidoscabe
create procedure usp_003
	@p_idc char(10),@p_cp smallint output
as
begin 
 SET @p_cp=(select COUNT(idpedido)from Ventas.pedidoscabe where IdCliente=@p_idc)
 end
 go
-- execute usp_003 'ANTON','3'

 begin 
 declare @idcli char(10)='ANTON'
 declare @cantp smallint 
 execute usp_003 @p_idc=@idcli,@p_cp=@cantp output
 print 'El cliente : '+@idcli
 print 'Ha realizado '+cast(@cantp as varchar(15))+' pedidos'
 end

 create proc usp_ingcat
 @idcat int,
 @nomcat varchar(50),
 @descrip varchar(max)
 as
 begin
  insert Compras.categorias
  values(@idcat,@nomcat,@descrip)
end
go
--exec usp_ingcat 9,'ded','sdfsdf'

select*from Compras.categorias
create proc usp_acCat
@idcat2 int,
@nomCat2 varchar(50),
@descrip2 varchar(max)
as
begin 
	update Compras.categorias
	set nombrecategoria=@nomCat2,
	Descripcion=@descrip2
	where IdCategoria=@idcat2
end
go

exec usp_ingcat 10,'fdghfdgfd','dfsad'

create procedure usp_trancat
@tiptran int,@idcat int,@nomcat varchar(45),@descrip varchar(max)
as
begin
	if @tiptran=1
		begin 
			if not exists (select*from  Compras.categorias where IdCategoria=@idcat)
				execute usp_ingcat @idcat,@nomcat,@descrip
			else
				raiserror ('el id categoria existe',10,1)
		end
	if @tiptran=2
	BEGIN
		IF EXISTS (SELECT*from Compras.categorias where IdCategoria=@idcat)
			begin
				if @nomcat is null
					set @nomcat=(select nombrecategoria from Compras.categorias where IdCategoria=@idcat)
				if @descrip is null
					set @descrip=(select descripcion from Compras.categorias where IdCategoria=@idcat)

			end
		else
			raiserror('El id categoria no xiste',110,1)
	end
end

exec usp_trancat 1,12,'fgggggggg','hgjhhhhhhhhhhhhhg'
exec usp_trancat 1,12,'dddd','dsdfdh52hg'
exec usp_trancat 1,13,'aaaaaaaaa','bbbbbbbbbb'
exec usp_trancat 1,55,'ccccc','ddddddd'
exec usp_trancat 2,55,null,'6163fdgd'
select*from Compras.categorias

create proc usp_procur
@idcli varchar(10)
as
begin
	declare pedido cursor for select IdPedido,FechaPedido from Ventas.pedidoscabe where IdCliente=@idcli
	declare @idped int,@fped date
	open pedido
	fetch pedido into @idped,@fped
	print space(5)+'pedido'+space(10)+'fecha'
	print replicate('=',50)
	while @@FETCH_STATUS=0
	begin 
		print  space(5)+cast(@idped as varchar(10))+space(10)+cast(@fped as varchar(12))
		fetch pedido into  @idped,@fped
	end
	close pedido
	deallocate pedido
end
select*from Ventas.pedidoscabe
drop proc usp_procur
exec usp_procur 'ALFKI'

CREATE PROCEDURE SP_NUEVOCLI
@IDCLI VARCHAR(5),
@NOM VARCHAR(40),
@DIR VARCHAR(60),
@IDPA CHAR(3),
@FONO VARCHAR(25)
AS
BEGIN
	INSERT INTO Ventas.clientes VALUES (@IDCLI,@NOM,@DIR,@IDPA,@FONO)
END
GO

CREATE PROC SP_INGRESAR
@IDCLI VARCHAR(5),
@NOM VARCHAR(40),
@DIR VARCHAR(60),
@IDPA CHAR(3),
@FONO VARCHAR(25)
AS
BEGIN
	BEGIN TRY 
	begin tran t
		EXEC SP_NUEVOCLI @IDCLI,@nom,@DIR,@IDPA,@FONO
		IF @IDPA!= '002'
			commit tran t
		else
			raiserror('id pais no permitido',16,1)

	END TRY
	begin catch
		print error_message()
		rollback tran t
	end catch
end
go
	
	drop proc SP_INGRESAR

exec SP_INGRESAR 'FFFFF','asdasd','sdfasdasdasd','009','fhjfh'
exec SP_INGRESAR '00000','fdgdfg','sdfasdasdasd','002','fhjfh'
select*from Ventas.clientes

create function preProm()
	RETURNS DECIMAL
AS
	BEGIN
		DECLARE @PROM DECIMAL
		SELECT @PROM=AVG(PRECIOUNIDAD) FROM Compras.productos
		RETURN @PROM
	END
GO
print 'precio promedio '+str(dbo.preProm(),3)

select dbo.preProm()

select*from Compras.productos where PrecioUnidad>dbo.preProm()
go
