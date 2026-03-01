use pruebas
go

SET NOCOUNT ON

-- Declaracion de variables
declare
@w_return           int,

@w_estado           char(1),
@w_gap              int,
@w_hasta            bigint,
@w_recorre          bigint,

@w_delta            float,
@w_pi               float,
@w_c                float,
@w_f                float,

@w_radio_esfera     int,
@w_px_e             float,
@w_py_e             float,
@w_pz_e             float,

@w_radio            int,
@w_px               float,
@w_py               float,
@w_pz               float,

@w_primoanterior    bigint,
@w_angulo           float

-- Asignacion de variables
select @w_gap            = 0
select @w_recorre        = 0
select @w_radio_esfera   = 5
select @w_delta          = 57.29577  -- Pinta un Numero por Radian
select @w_pi             = 3.14159
select @w_radio          = 5
select @w_primoanterior  = 0
select @w_angulo         = 0.0

-- Casos a estudiar
select @w_hasta = 10000

-- Recorrido de los numeros
while (@w_recorre < @w_hasta)
begin
    -- Aumento en contadores
    select @w_recorre = @w_recorre + 1
    select @w_gap = @w_gap + 1

    -- Determina si es primo o no
    exec @w_return = sp_pr_primos @w_recorre

    -- Cálculo de las coordenadas X, Y, Z del plano
    select @w_px    = (@w_radio * @w_gap * Cos((@w_recorre % 360) * @w_delta * (@w_pi / 180))) 
    select @w_py    = (@w_radio * @w_gap * Sin((@w_recorre % 360) * @w_delta * (@w_pi / 180)))
    select @w_pz    = 0

    -- Calculo del factor comun en las ecuaciones
    select @w_c     = ( POWER(@w_px, 2) + POWER(@w_py, 2) )
    select @w_f     = 100000

    -- Cálculo de las coordenadas X, Y, Z de la esfera
    select @w_px_e  = ( 2 * @w_px  / (@w_c + 1) ) * @w_f
    select @w_py_e  = ( 2 * @w_py  / (@w_c + 1) ) * @w_f
    select @w_pz_e  = ( (@w_c - 1) / (@w_c + 1) ) * @w_f

    -- Calcula el angulo
    if @w_return = 1 
    begin
        select @w_angulo = (360.000000 / @w_recorre) * ( @w_recorre - @w_primoanterior )    -- x = (p2-p1) * 360 / p2
        select @w_primoanterior = @w_recorre
    end
    else
    begin
        select @w_angulo = 0.0
    end

   -- select top 10 * from pr_primos    
   -- delete pr_primos

    -- Determina el estado
    if @w_return = 1
    begin 
        select @w_estado = 'P'  
    end
    else
    begin
        select @w_estado = 'C'
    end

    -- Muestra los resultados
    --select @w_recorre as 'Numero', @w_estado as 'Primo', @w_gap as 'Gap', @w_x_esfera as 'X-Esfera', @w_y_esfera as 'Y-Esfera', @w_z_esfera as 'Z-Esfera'

    -- Inserta los valores en la tabla
    insert into pr_primos (
    pr_numero,     pr_estado,      pr_gap,
    pr_posx,       pr_posy,        pr_posz,
    pr_angulo,     pr_posxe,       pr_posye,
    pr_posze)
    values (
    @w_recorre,    @w_estado,      @w_gap,
    @w_px,         @w_py,          @w_pz,
    @w_angulo,     @w_px_e,        @w_py_e, 
    @w_pz_e )

    -- Reseteo del gap
    if  @w_return = 1 
    begin
        select @w_gap = 0
    end
end

-- Update a la unidad
update pr_primos set pr_estado = 'U' where pr_numero = 1

SET NOCOUNT OFF

go


