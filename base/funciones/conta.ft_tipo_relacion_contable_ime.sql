--------------- SQL ---------------

CREATE OR REPLACE FUNCTION conta.ft_tipo_relacion_contable_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Contabilidad
 FUNCION: 		conta.ft_tipo_relacion_contable_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'conta.ttipo_relacion_contable'
 AUTOR: 		 (admin)
 FECHA:	        16-05-2013 21:51:43
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_tipo_relacion_contable	integer;
    v_tiene_aplicacion 			varchar;
    v_codigo_aplicacion_catalogo	varchar;
			    
BEGIN

    v_nombre_funcion = 'conta.ft_tipo_relacion_contable_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'CONTA_TIPRELCO_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		16-05-2013 21:51:43
	***********************************/

	if(p_transaccion='CONTA_TIPRELCO_INS')then
					
        begin
        
             IF pxp.f_existe_parametro(p_tabla, 'tiene_aplicacion') THEN
                v_tiene_aplicacion = v_parametros.tiene_aplicacion;
             ELSE
               v_tiene_aplicacion = 'no';
             END IF;
             
             IF pxp.f_existe_parametro(p_tabla, 'codigo_aplicacion_catalogo') THEN
                v_codigo_aplicacion_catalogo = v_parametros.codigo_aplicacion_catalogo;
             ELSE
               v_codigo_aplicacion_catalogo = NULL;
             END IF;
        
             --validamos que solo peude tener un criterio extra a la vez (tiene_tipo_centro,tiene_moneda, tiene_aplicacion )
              
             
            IF   (v_parametros.tiene_moneda = 'si' and   v_parametros.tiene_tipo_centro = 'no' and   v_tiene_aplicacion  = 'no')
                 OR (v_parametros.tiene_moneda = 'no' and   v_parametros.tiene_tipo_centro = 'si' and   v_tiene_aplicacion  = 'no') 
                 OR (v_parametros.tiene_moneda = 'no' and   v_parametros.tiene_tipo_centro = 'no' and   v_tiene_aplicacion  = 'si')
                 OR (v_parametros.tiene_moneda = 'no' and   v_parametros.tiene_tipo_centro = 'no' and   v_tiene_aplicacion  = 'no')   THEN
                     
                      raise notice 'conbinacion valida';
            ELSE   
                     raise exception 'Solo es valida una una opción a la vez (tiene_tipo_centro, tiene_moneda, tiene_aplicacion )';
            END IF;
         
        
        	--Sentencia de la insercion
        	insert into conta.ttipo_relacion_contable(
                      estado_reg,
                      nombre_tipo_relacion,
                      tiene_centro_costo,
                      codigo_tipo_relacion,
                      id_tabla_relacion_contable,
                      fecha_reg,
                      id_usuario_reg,
                      fecha_mod,
                      id_usuario_mod,
                      tiene_partida,
                      tiene_auxiliar,
                      partida_tipo,
                      partida_rubro,
                      tiene_aplicacion,
                      tiene_moneda,
                      tiene_tipo_centro,
                      codigo_aplicacion_catalogo
                      
          	) values(
            
                      'activo',
                      v_parametros.nombre_tipo_relacion,
                      v_parametros.tiene_centro_costo,
                      v_parametros.codigo_tipo_relacion,
                      v_parametros.id_tabla_relacion_contable,
                      now(),
                      p_id_usuario,
                      null,
                      null,
                      v_parametros.tiene_partida,
                      v_parametros.tiene_auxiliar,
                      v_parametros.partida_tipo,
                      v_parametros.partida_rubro,
                      v_tiene_aplicacion,
                      v_parametros.tiene_moneda,
                      v_parametros.tiene_tipo_centro,
                      v_codigo_aplicacion_catalogo	
                      			
			)RETURNING id_tipo_relacion_contable into v_id_tipo_relacion_contable;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo Relacion Contable almacenado(a) con exito (id_tipo_relacion_contable'||v_id_tipo_relacion_contable||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_relacion_contable',v_id_tipo_relacion_contable::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'CONTA_TIPRELCO_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		16-05-2013 21:51:43
	***********************************/

	elsif(p_transaccion='CONTA_TIPRELCO_MOD')then

		begin
        
        
             IF pxp.f_existe_parametro(p_tabla, 'tiene_aplicacion') THEN
                v_tiene_aplicacion = v_parametros.tiene_aplicacion;
             ELSE
               v_tiene_aplicacion = 'no';
             END IF;
             
             IF pxp.f_existe_parametro(p_tabla, 'codigo_aplicacion_catalogo') THEN
                v_codigo_aplicacion_catalogo = v_parametros.codigo_aplicacion_catalogo;
             ELSE
               v_codigo_aplicacion_catalogo = NULL;
             END IF;
        
           	IF   (v_parametros.tiene_moneda = 'si' and   v_parametros.tiene_tipo_centro = 'no' and   v_tiene_aplicacion  = 'no')
                 OR (v_parametros.tiene_moneda = 'no' and   v_parametros.tiene_tipo_centro = 'si' and   v_tiene_aplicacion  = 'no') 
                 OR (v_parametros.tiene_moneda = 'no' and   v_parametros.tiene_tipo_centro = 'no' and   v_tiene_aplicacion  = 'si')
                 OR (v_parametros.tiene_moneda = 'no' and   v_parametros.tiene_tipo_centro = 'no' and   v_tiene_aplicacion  = 'no')   THEN
                     
                      raise notice 'conbinacion valida';
            ELSE   
                     raise exception 'Solo es valida una una opción a la vez (tiene_tipo_centro, tiene_moneda, tiene_aplicacion )';
            END IF;
            
            
			--Sentencia de la modificacion
			update conta.ttipo_relacion_contable set
            
                  nombre_tipo_relacion = v_parametros.nombre_tipo_relacion,
                  tiene_centro_costo = v_parametros.tiene_centro_costo,
                  tiene_partida = v_parametros.tiene_partida,
                  tiene_auxiliar = v_parametros.tiene_auxiliar,
                  codigo_tipo_relacion = v_parametros.codigo_tipo_relacion,
                  id_tabla_relacion_contable = v_parametros.id_tabla_relacion_contable,
                  fecha_mod = now(),
                  id_usuario_mod = p_id_usuario,
                  partida_tipo = v_parametros.partida_tipo,
                  partida_rubro = v_parametros.partida_rubro,
                  tiene_aplicacion = v_tiene_aplicacion,
                  tiene_moneda =  v_parametros.tiene_moneda,
                  tiene_tipo_centro = v_parametros.tiene_tipo_centro,
                  codigo_aplicacion_catalogo = v_codigo_aplicacion_catalogo
                  
			where id_tipo_relacion_contable=v_parametros.id_tipo_relacion_contable;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo Relacion Contable modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_relacion_contable',v_parametros.id_tipo_relacion_contable::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'CONTA_TIPRELCO_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		16-05-2013 21:51:43
	***********************************/

	elsif(p_transaccion='CONTA_TIPRELCO_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from conta.ttipo_relacion_contable
            where id_tipo_relacion_contable=v_parametros.id_tipo_relacion_contable;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo Relacion Contable eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_relacion_contable',v_parametros.id_tipo_relacion_contable::varchar);
              
            --Devuelve la respuesta
            return v_resp;

		end;
         
	else
     
    	raise exception 'Transaccion inexistente: %',p_transaccion;

	end if;

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