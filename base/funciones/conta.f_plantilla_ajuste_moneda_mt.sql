--------------- SQL ---------------

CREATE OR REPLACE FUNCTION conta.f_plantilla_ajuste_moneda_mt (
  p_id_usuario integer,
  p_id_int_comprobante integer,
  p_id_gestion_cbte integer,
  p_desde date,
  p_hasta date,
  p_id_depto integer
)
RETURNS void AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Contabilidad
 FUNCION: 		conta.f_plantilla_ajuste_moneda_mt
 DESCRIPCION:   Funcion que devuelve conjuntos suma por centro de costos
 AUTOR: 		 (MMV)
 FECHA:	        19/12/2018
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:
 ISSUE 		   FECHA   			 AUTOR				    DESCRIPCION:
 #32  ETR	  08/01/2019		  MMV					Plantilla ajuste moneda MA y MT


***************************************************************************/
DECLARE
	v_nombre_funcion   				text;
 	v_resp							varchar;
	v_record						record;
    v_sw_actualiza    				boolean;

    v_importe_debe					numeric;
    v_importe_haber				    numeric;
    v_saldo_mb   					numeric;

    v_reg_cbte						record;
    v_sw_minimo						boolean;
    v_partida_debe					integer;
  	v_partida_haber					integer;
  	v_id_centro_costo_depto  		integer;
  	v_record_mov					record;

    v_saldo_mt							numeric;
    v_saldo_ma							numeric;

    v_importe_debe_ma					numeric;
    v_importe_haber_ma				    numeric;
    v_importe_debe_mt					numeric;
    v_importe_haber_mt				    numeric;

    v_sw_saldo_acredor 					boolean;

    v_aux_debe		numeric;
    v_aux_heber		numeric;
   	v_id_partida    integer;
    v_cuenta		integer;
    v_centro_costo  integer;
    v_total_haber_ma   				numeric;
    v_total_debe_ma	 				numeric;
    v_total_haber_mt   				numeric;
    v_total_debe_mt	 				numeric;
    v_total_haber   				numeric;
  	v_total_debe	 				numeric;
    v_ajuste_haber 					numeric;
    v_ajuste_debe					numeric;
    v_partida						integer;
    v_auxiliar						integer;
BEGIN

 	v_nombre_funcion = 'conta.f_plantilla_ajuste_moneda_mt';

	v_total_debe_mt = 0;
    v_total_haber_mt = 0;

    v_ajuste_haber = 0;
    v_ajuste_debe = 0;

      select  *
              into
              v_reg_cbte
      from conta.tint_comprobante
      where id_int_comprobante = p_id_int_comprobante;

	  FOR v_record_mov in ( with basica as (select     t.id_centro_costo,
                                                    t.id_cuenta,
                                                    COALESCE(t.id_auxiliar,0) as id_auxiliar,
                                                    /*case
                                                       when par.id_partida is not NULL then
                                                         par.id_partida
                                                        else
                                                           0
                                                        end as id_partida,*/
                                                    case
                                                       when  par.sw_movimiento = 'presupuestaria' then
                                                         par.id_partida
                                                        else
                                                           0
                                                        end as id_partida,    
                                                        
                                                    t.importe_debe_mb,
                                                    t.importe_haber_mb,
                                                    t.importe_debe_mt,
                                                    t.importe_haber_mt,
                                                    t.importe_debe_ma,
                                                    t.importe_haber_ma
                                              from conta.tint_transaccion t
                                              inner join conta.tint_comprobante cb on cb.id_int_comprobante = t.id_int_comprobante
                                              inner join  pre.tpartida par on par.id_partida = t.id_partida
                                              inner join conta.tcuenta cu on cu.id_cuenta = t.id_cuenta
                                              inner join conta.tconfig_subtipo_cuenta su on su.id_config_subtipo_cuenta = cu.id_config_subtipo_cuenta
                                              inner join conta.tconfig_tipo_cuenta tc on tc.id_config_tipo_cuenta = su.id_config_tipo_cuenta
                                              inner join param.tperiodo pe on pe.id_periodo = cb.id_periodo
                                              where cb.estado_reg = 'validado'  and tc.tipo_cuenta in ('activo','patrimonio','pasivo')
                                              and pe.id_gestion = p_id_gestion_cbte and  cb.fecha::date BETWEEN p_desde and p_hasta),
                                saldo as (   select t.id_centro_costo,
                                                      t.id_cuenta,
                                                      t.id_auxiliar,
                                                      t.id_partida,
                                                      sum(COALESCE(t.importe_debe_mb,0)) as importe_debe_mb,
                                                      sum(COALESCE(t.importe_haber_mb,0)) as importe_haber_mb,
                                                      
                                                      (sum(COALESCE(t.importe_debe_mb,0)) - sum(COALESCE(t.importe_haber_mb,0))) as saldo_mb,
                                                      
                                                      sum(COALESCE(t.importe_debe_mt,0)) as importe_debe_mt,
                                                      sum(COALESCE(t.importe_haber_mt,0)) as importe_haber_mt,
                                                      
                                                      (sum(COALESCE(t.importe_debe_mt,0)) - sum(COALESCE(t.importe_haber_mt,0)) )as saldo_mt,
                                                      
                                                      sum(COALESCE(t.importe_debe_ma,0)) as importe_debe_ma,
                                                      sum(COALESCE(t.importe_haber_ma,0))as importe_haber_ma,
                                                      
                                                      (sum(COALESCE(t.importe_debe_ma,0)) - sum(COALESCE(t.importe_haber_ma,0)) ) as saldo_ma
                                                      from basica t
                                                      group by
                                                            t.id_centro_costo,
                                                            t.id_cuenta,
                                                            t.id_auxiliar,
                                                            t.id_partida)
                                                            select  t.id_centro_costo,
                                                                    t.id_cuenta,
                                                                    t.id_auxiliar,
                                                                    t.id_partida,
                                                                    t.importe_debe_mb as deudor,--MB
                                                                    t.importe_haber_mb as acreedor,
                                                                    t.importe_debe_mt,--MT
                                                                    t.importe_haber_mt,
                                                                    t.importe_debe_ma,--MA
                                                                    t.importe_haber_ma
                                                            from saldo t 
                                              where t.saldo_mb = 0 and t.saldo_mt <> 0)LOOP


                    v_sw_actualiza = false;
                    v_sw_saldo_acredor = false;

                    v_saldo_ma = 0;
					v_saldo_mb = 0;
					v_saldo_mt = 0;

                     IF v_record_mov.importe_debe_mt > v_record_mov.importe_haber_mt  THEN
                                v_sw_saldo_acredor = true;
                                v_sw_actualiza = true;
                                v_saldo_mt = v_record_mov.importe_debe_mt - v_record_mov.importe_haber_mt;

                     ELSEIF v_record_mov.importe_haber_mt > v_record_mov.importe_debe_mt THEN

                               v_sw_saldo_acredor = false;
                               v_sw_actualiza = true;
                               v_saldo_mt = v_record_mov.importe_haber_mt - v_record_mov.importe_debe_mt;

                     END IF;

      		IF v_saldo_mt <> 0 then
                    IF v_sw_actualiza THEN

                        v_importe_debe = 0;
                        v_importe_haber = 0;

                        v_importe_debe_ma = 0;
                        v_importe_haber_ma = 0;

                        v_importe_debe_mt = 0;
                        v_importe_haber_mt = 0;

                        IF v_sw_saldo_acredor THEN

                                v_importe_haber = 0;
                                v_importe_debe = 0;

                                v_importe_haber_ma  = 0;
                                v_importe_debe_ma	= 0;

								v_importe_haber_mt 	= v_saldo_mt;
                                v_importe_debe_mt 	= 0;

                          select  ps_id_cuenta,
                                  ps_id_centro_costo,
                                  ps_id_partida,
                                  ps_id_auxiliar
                            into
                                v_cuenta,
                                v_centro_costo,
                                v_partida,
                                v_auxiliar
                          from conta.f_get_config_relacion_contable( 'GAN-RD',
                                                                       p_id_gestion_cbte,
                                                                       null,  --campo_relacion_contable
                                                                       null);



                        ELSE
                                v_importe_haber = 0;
                                v_importe_debe 	= 0;

                                v_importe_haber_ma  = 0;
                                v_importe_debe_ma	= 0;

								v_importe_haber_mt 	= 0;
                                v_importe_debe_mt 	= v_saldo_mt;
                                
                    select  ps_id_cuenta,
                            ps_id_centro_costo,
                            ps_id_partida,
                            ps_id_auxiliar
                        into
                            v_cuenta,
                            v_centro_costo,
                            v_partida,
                            v_auxiliar						
                      from conta.f_get_config_relacion_contable( 'PER-RD',
                                                                   p_id_gestion_cbte,
                                                                   null,  --campo_relacion_contable
                                                                   null);



                        END IF;
						v_total_debe = 0;
                        v_total_haber = 0;

                      	v_total_debe_ma  = 0;
                      	v_total_haber_ma  = 0;

                      	v_total_debe_mt  = v_total_debe_mt + v_importe_haber_mt;
                       	v_total_haber_mt  = v_total_haber_mt + v_importe_debe_mt;

                        insert into conta.tint_transaccion(
                                    id_partida,
                                    id_centro_costo,
                                    estado_reg,
                                    id_cuenta,
                                    glosa,
                                    id_int_comprobante,
                                    id_auxiliar,
                                    importe_debe,
                                    importe_haber,
                                    importe_gasto,
                                    importe_recurso,
                                    importe_debe_mb,
                                    importe_haber_mb,
                                    importe_gasto_mb,
                                    importe_recurso_mb,
                                    importe_debe_mt,
                                    importe_haber_mt,
                                    importe_gasto_mt,
                                    importe_recurso_mt,
                                    importe_debe_ma,
                                    importe_haber_ma,
                                    importe_gasto_ma,
                                    importe_recurso_ma,
                                    id_usuario_reg,
                                    fecha_reg,
                                    actualizacion,
                                    id_moneda,
									tipo_cambio,
									tipo_cambio_2
                                ) values(
                                   case
                                      when v_record_mov.id_partida = 0 then
                                          v_partida
                                      else
                                          v_record_mov.id_partida
                                      end,
                                    v_record_mov.id_centro_costo,
                                    'activo',
                                    v_record_mov.id_cuenta,
                                    'Asiento ajuste monde MT',
                                    p_id_int_comprobante,
                                     case
                                      when v_record_mov.id_auxiliar = 0 then
                                          null
                                      else
                                          v_record_mov.id_auxiliar
                                      end,
                                    v_importe_debe_mt,
                                    v_importe_haber_mt,
                                    v_importe_debe_mt,
                                    v_importe_haber_mt, --BS
                  					0,0,0,0, --MB
                                    v_importe_debe_mt,
                                    v_importe_haber_mt,
                                    v_importe_debe_mt,
                                    v_importe_haber_mt, --MT
                                    0,0,0,0, --MA
                                    p_id_usuario,
                                    now(),
                                    'si',
                                    2,
                                    6.96,
                                    1);

				v_sw_minimo = true;
                ELSE
                    raise exception 'Error';
                END IF;
			END IF;
          END LOOP;

    IF not v_sw_minimo THEN
       raise exception 'No se actualizo ninguna cuenta';
    END IF;



            v_ajuste_debe = v_total_debe_mt;
           	v_ajuste_haber =  0;

           select ps_id_cuenta,
                  ps_id_centro_costo,
                  ps_id_partida,
                  ps_id_auxiliar
              into
                  v_cuenta,
                  v_centro_costo,
                  v_partida,
                  v_auxiliar
            from conta.f_get_config_relacion_contable( 'PER-RD',
                                                         p_id_gestion_cbte,
                                                         null,  --campo_relacion_contable
                                                         null);
          IF v_cuenta is null THEN
             raise exception 'No se encontro relacion contablePER-RD';
          END IF;

          insert into conta.tint_transaccion(
                  id_partida,
                  id_centro_costo,
                  estado_reg,
                  id_cuenta,
                  glosa,
                  id_int_comprobante,
                  id_auxiliar,

                  importe_debe,
                  importe_haber,
                  importe_gasto,
                  importe_recurso,

                  importe_debe_mb,
                  importe_haber_mb,
                  importe_gasto_mb,
                  importe_recurso_mb,

                  importe_debe_mt,
                  importe_haber_mt,
                  importe_gasto_mt,
                  importe_recurso_mt,

                  importe_debe_ma,
                  importe_haber_ma,
                  importe_gasto_ma,
                  importe_recurso_ma,

                  id_usuario_reg,
                  fecha_reg,
                  actualizacion,
                  id_moneda,
                  tipo_cambio,
                  tipo_cambio_2
              ) values(
                  v_partida,
                  v_centro_costo,
                  'activo',
                  v_cuenta,
                  'Asiento ajuste monde MT1',
                  p_id_int_comprobante,
                  v_auxiliar,
                  v_ajuste_debe,
                  v_ajuste_haber,
                  v_ajuste_debe,
                  v_ajuste_haber, --BS
                  0,0,0,0, --MB
                  v_ajuste_debe,
                  v_ajuste_haber,
                  v_ajuste_debe,
                  v_ajuste_haber, --MT
                  0,0,0,0, --MA
                  p_id_usuario,
                  now(),
                  'si',
                  2,
                  6.96,
                  1
                  );


           v_ajuste_debe = 0;
           v_ajuste_haber = v_total_haber_mt;

             select ps_id_cuenta,
                    ps_id_centro_costo,
                    ps_id_partida,
                    ps_id_auxiliar
              into
                  v_cuenta,
                  v_centro_costo,
                  v_partida,
                  v_auxiliar
            from conta.f_get_config_relacion_contable( 'GAN-RD',
                                                         p_id_gestion_cbte,
                                                         null,  --campo_relacion_contable
                                                         null);

          IF v_cuenta is null THEN
             raise exception 'No se encontro relacion contable GAN-RD';
          END IF;

          insert into conta.tint_transaccion(
                  id_partida,
                  id_centro_costo,
                  estado_reg,
                  id_cuenta,
                  glosa,
                  id_int_comprobante,
                  id_auxiliar,

                  importe_debe,
                  importe_haber,
                  importe_gasto,
                  importe_recurso,

                  importe_debe_mb,
                  importe_haber_mb,
                  importe_gasto_mb,
                  importe_recurso_mb,

                  importe_debe_mt,
                  importe_haber_mt,
                  importe_gasto_mt,
                  importe_recurso_mt,

                  importe_debe_ma,
                  importe_haber_ma,
                  importe_gasto_ma,
                  importe_recurso_ma,

                  id_usuario_reg,
                  fecha_reg,
                  actualizacion,
                  id_moneda,
                  tipo_cambio,
                  tipo_cambio_2
                  ) values(
                  v_partida,
                  v_centro_costo,
                  'activo',
                  v_cuenta,
                  'Asiento ajuste monde MT2',
                  p_id_int_comprobante,
                  v_auxiliar,
                  v_ajuste_debe,
                  v_ajuste_haber,
                  v_ajuste_debe,
                  v_ajuste_haber, --BS
                  0,0,0,0, --MB
                  v_ajuste_debe,
                  v_ajuste_haber,
                  v_ajuste_debe,
                  v_ajuste_haber, --MT
                  0,0,0,0, --MA
                  p_id_usuario,
                  now(),
                  'si',
                  2,
                  6.96,
                  1
              );


	update conta.tint_comprobante set
    id_moneda = 2,
    tipo_cambio = 6.96,
    tipo_cambio_2 = 1
    where id_int_comprobante = p_id_int_comprobante;

EXCEPTION

	WHEN OTHERS THEN
		v_resp='';
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
		raise exception '%',v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;