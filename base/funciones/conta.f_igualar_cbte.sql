--------------- SQL ---------------

CREATE OR REPLACE FUNCTION conta.f_igualar_cbte (
  p_id_int_comprobante integer,
  p_id_usuario integer,
  p_show_errors boolean = true
)
RETURNS boolean AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Contabilidad
 FUNCION: 		conta.f_igualar_cbte
 DESCRIPCION:    funcion que iguala los monto debe haber de la transaccion por diferencia de redondeo o  de tipo de cambia
 AUTOR: 		 (rac)  kplian
 FECHA:	        19-11-2015 12:39:12
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE

	v_errores								varchar;
    v_resp									varchar;
	v_nombre_funcion						varchar;
    v_monto_debe							numeric;
    v_monto_haber							numeric;
    v_monto_debe_mb							numeric;
    v_monto_haber_mb						numeric;
    v_monto_debe_mt							numeric;
    v_monto_haber_mt						numeric;
    v_conta_error_limite_redondeo			numeric;
    v_registros					     	    record;
    v_registros_rel	   				  	    record;
    v_debe							numeric;
    v_haber							numeric;
    
    v_debe_mb						numeric;
    v_haber_mb						numeric;
    v_debe_mt						numeric;
    v_haber_mt						numeric;
    v_variacion_mb					numeric;
    v_variacion_mt					numeric;
    v_variacion						numeric;
    v_tipo_cambio  					numeric;
    v_tipo_cambio_2  				numeric;
    v_cont_tc1						integer;
    v_cont_tc2						integer;
    v_relacion						varchar;
    v_id_int_transaccion			integer;
    v_glosa							varchar;

 

BEGIN

     v_nombre_funcion = 'conta.f_igualar_cbte';
   
      --solo igualar cbtes en borrador
              
 
   
   
              select 
                c.*,
                p.id_gestion
              into
               v_registros
              from conta.tint_comprobante c
              inner join param.tperiodo p on p.id_periodo = c.id_periodo
              where c.id_int_comprobante = p_id_int_comprobante;
    			
           
            IF p_show_errors THEN
              IF v_registros.estado_reg != 'borrador'  THEN
                raise exception 'Solo puede igualar cbtes en borrador';
              END IF;
            END IF;  
                -- sumar las transacciones en todas las monedas
             select 
                   sum(tra.importe_debe), 
                   sum(tra.importe_haber),
                   sum(tra.importe_debe_mb), 
                   sum(tra.importe_haber_mb),
                   sum(tra.importe_debe_mt), 
                   sum(tra.importe_haber_mt)
              into 
                 v_debe, 
                 v_haber,
                 v_debe_mb, 
                 v_haber_mb,
                 v_debe_mt, 
                 v_haber_mt
              from conta.tint_transaccion tra
              where tra.id_int_comprobante = p_id_int_comprobante;
              
              
               --calcular  las diferencias,  y como igualar
           
              if v_debe < v_haber then
                 v_variacion = v_haber - v_debe;
                 v_monto_debe =  v_variacion;
                 v_monto_haber =  0;
                 
              elsif v_debe > v_haber then
                 v_variacion =  v_debe - v_haber;
                 v_monto_debe =  0;
                 v_monto_haber =  v_variacion;
              else
                 v_monto_debe =  0;
                 v_monto_haber =  0;
              end if;
              
              
              if v_debe_mb < v_haber_mb then
                 v_variacion_mb = v_haber_mb - v_debe_mb;
                 v_monto_debe_mb =  v_variacion_mb;
                 v_monto_haber_mb =  0;
              elsif v_debe_mb > v_haber_mb then
                 v_variacion_mb =  v_debe_mb - v_haber_mb;
                 v_monto_debe_mb =  0;
                 v_monto_haber_mb =  v_variacion_mb;
              else
                 v_monto_debe_mb =  0;
                 v_monto_haber_mb =  0;
              end if;
              
              
              if v_debe_mt < v_haber_mt then
                 
                 v_variacion_mt = v_haber_mt - v_debe_mt;
                 v_monto_debe_mt =  v_variacion_mt;
                 v_monto_haber_mt =  0;
              
              elsif v_debe_mt > v_haber_mt then
                 
                 v_variacion_mt = v_debe_mt -  v_haber_mt;
                  v_monto_debe_mt =  0;
                 v_monto_haber_mt =  v_variacion_mt;
              else
                 v_monto_debe_mt =  0;
                 v_monto_haber_mt =  0;
              end if;
              
              ----------------------------------------
              --determina si exiten diferencias
              ----------------------------------------
              
             
              v_errores='';
              if  v_variacion > 0  then
                  v_errores = 'El comprobante no iguala: Diferencia '||v_variacion::varchar;
              end if;
                  
              if  v_variacion_mb > 0  then
                  v_errores = 'El comprobante no iguala en moneda base: Diferencia '||v_variacion_mb::varchar;
              end if;
                  
              if  v_variacion_mt > 0  then
                  v_errores = 'El comprobante no iguala en moneda de triangulación: Diferencia  '||v_variacion_mt::varchar;
              end if;
                  
              IF v_errores = '' THEN
              
                 IF p_show_errors THEN
                 	raise exception 'No existen diferencias para igualar';
                 ELSE
                    RETURN TRUE;
                 END IF;
              END IF; 
              
             
              -------------------------------------------------------
              -- detectar si existe diferencia por tipo de cambio
              -----------------------------------------------------
              select
                count (DISTINCT (tipo_cambio))
              into
                v_cont_tc1
              from conta.tint_transaccion t
              where t.id_int_comprobante = p_id_int_comprobante and t.actualizacion != 'si';


              select
                count (DISTINCT (tipo_cambio_2))
              into
                v_cont_tc2
              from conta.tint_transaccion t
              where t.id_int_comprobante = p_id_int_comprobante and t.actualizacion != 'si';
           
             ------------------------------------------------------------------------------------------------------------ 
             -- si la diferencia es en moneda de la trasaccion verifica que el el margen no supere el limte establecido
             ------------------------------------------------------------------------------------------------------------
             
               --recupera el margen de la configuracion global
               
              v_conta_error_limite_redondeo  = pxp.f_get_variable_global('conta_error_limite_redondeo')::numeric;
               
            
               
              if  v_variacion > 0  then
                  IF v_conta_error_limite_redondeo < v_variacion THEN
                     raise exception 'La diferencia   en moneda transaccional, (%),  excede el margen establecido de (%),  igualé  manualmente, ',v_variacion, v_conta_error_limite_redondeo;
                  ELSE
                  
                 
                  IF v_debe >  v_haber   THEN
                    v_relacion = 'GAN-RD';
                  ELSE
                    v_relacion = 'PER-RD';
                  END IF;
                    
                    
                -- determinar relacion contable de perdida o ganacia por redondeo
                  SELECT 
                    * 
                   into 
                     v_registros_rel
                 FROM conta.f_get_config_relacion_contable(v_relacion, -- relacion contable que almacena los centros de costo por departamento
                                                           v_registros.id_gestion,  
                                                           v_registros.id_depto, 
                                                           NULL);  --id_dento_costo 
                     
                    
                    
                    -- insertar transaccion para igual moneda de transaccion
                     
                    insert into conta.tint_transaccion(
                        id_partida,
                        id_auxiliar,
                        id_centro_costo,
                        estado_reg,
                        id_cuenta,
                        glosa,
                        id_int_comprobante,
                      
                        importe_debe,
                        importe_haber,
                        importe_gasto,
                        importe_recurso,
                        id_usuario_reg,
                        fecha_reg,
                        tipo_cambio,
                        tipo_cambio_2,
                        id_moneda,
                        id_moneda_tri
                        
                    ) values(
                        v_registros_rel.ps_id_partida,
                        v_registros_rel.ps_id_auxiliar,
                        v_registros_rel.ps_id_centro_costo,
                        'activo',
                        v_registros_rel.ps_id_cuenta,
                        'Igualación por diferencia de redondeo',
                        v_registros.id_int_comprobante,
                      
                        
                        v_monto_debe,
                        v_monto_haber,
                        v_monto_debe,
                        v_monto_haber,
                       
                        p_id_usuario,
                        now(),
                        v_registros.tipo_cambio,
                        v_registros.tipo_cambio_2,
                        v_registros.id_moneda,
                        v_registros.id_moneda_tri
                    )RETURNING id_int_transaccion into v_id_int_transaccion;
                    
                      -- calcular moneda base y triangulacion
                       PERFORM  conta.f_calcular_monedas_transaccion(v_id_int_transaccion);
                          
                      --llamada recursiva para igualar por redondeo o tipo de cambio
                       IF not conta.f_igualar_cbte(p_id_int_comprobante, p_id_usuario, FALSE) THEN
                         raise exception 'error al igual recursivamente';
                       END IF;
                       
                      RETURN TRUE;
                  END IF;
              end if;
             
             
             
              
              IF v_cont_tc2 >= 2 or v_cont_tc1 >= 2 THEN
                --------------------------------------
                --tenemos diferencia por tipo de cambio
                ---------------------------------------
                
                   IF v_debe_mb >  v_haber_mb   or  v_debe_mt  >  v_haber_mt THEN
                     v_relacion = 'GAN-DCB';
                   ELSE
                     v_relacion = 'PER-DCB';
                   END IF;
                    
                   v_glosa = 'Igualación por diferencia de cambio';
                 
              
              ELSE
                -----------------------------     
                --es diferencia por redondeo
                -----------------------------
                
                   -- recueperar relacion contable de diferencia de redondeo
                   
                   IF v_debe_mb >  v_haber_mb   or  v_debe_mt  >  v_haber_mt THEN
                     v_relacion = 'GAN-RD';
                   ELSE
                     v_relacion = 'PER-RD';
                   END IF;
                    
                   v_glosa = 'Igualación por diferencia de redondeo';
                                                           
              END IF;
              
              -- determinar relacion contable de perdida o ganancia por redondeo
                 
              SELECT 
                * 
              into 
                v_registros_rel
              FROM conta.f_get_config_relacion_contable( v_relacion, -- relacion contable que almacena los centros de costo por departamento
                                                             v_registros.id_gestion,  
                                                             v_registros.id_depto, 
                                                             NULL);  --id_dento_costo 
           
            
             
   
             insert into conta.tint_transaccion(
                        id_partida,
                        id_auxiliar,
                        id_centro_costo,
                        estado_reg,
                        id_cuenta,
                        glosa,
                        id_int_comprobante,
                       
                        
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
                        
                        id_usuario_reg,
                        fecha_reg,
                        tipo_cambio,
                        tipo_cambio_2,
                        id_moneda,
                        id_moneda_tri,
                        actualizacion
                        
                    ) values(
                        v_registros_rel.ps_id_partida,
                        v_registros_rel.ps_id_auxiliar,
                        v_registros_rel.ps_id_centro_costo,
                        'activo',
                        v_registros_rel.ps_id_cuenta,
                        v_glosa,
                        v_registros.id_int_comprobante,
                      
                        
                        0,
                        0,
                        0,
                        0,
                        
                        v_monto_debe_mb,
                        v_monto_haber_mb,
                        v_monto_debe_mb,
                        v_monto_haber_mb,
                        
                        v_monto_debe_mt,
                        v_monto_haber_mt,
                        v_monto_debe_mt,
                        v_monto_haber_mt,
                       
                        p_id_usuario,
                        now(),
                        0,
                        0,
                        v_registros.id_moneda,
                        v_registros.id_moneda_tri,
                        'si' --actulizacion
                    )RETURNING id_int_transaccion into v_id_int_transaccion;   
            
                                   
  
   
    return true;


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