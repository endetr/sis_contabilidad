CREATE OR REPLACE FUNCTION "conta"."ft_plantilla_calculo_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Contabilidad
 FUNCION: 		conta.ft_plantilla_calculo_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'conta.tplantilla_calculo'
 AUTOR: 		 (admin)
 FECHA:	        28-08-2013 19:01:20
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
	v_id_plantilla_calculo	integer;
			    
BEGIN

    v_nombre_funcion = 'conta.ft_plantilla_calculo_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'CONTA_PLACAL_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		28-08-2013 19:01:20
	***********************************/

	if(p_transaccion='CONTA_PLACAL_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into conta.tplantilla_calculo(
			prioridad,
			debe_haber,
			tipo_importe,
			id_plantilla,
			codigo_tipo_relacion,
			importe,
			descripcion,
			estado_reg,
			id_usuario_reg,
			fecha_reg,
			fecha_mod,
			id_usuario_mod
          	) values(
			v_parametros.prioridad,
			v_parametros.debe_haber,
			v_parametros.tipo_importe,
			v_parametros.id_plantilla,
			v_parametros.codigo_tipo_relacion,
			v_parametros.importe,
			v_parametros.descripcion,
			'activo',
			p_id_usuario,
			now(),
			null,
			null
							
			)RETURNING id_plantilla_calculo into v_id_plantilla_calculo;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Plantilla de Cálculo almacenado(a) con exito (id_plantilla_calculo'||v_id_plantilla_calculo||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_plantilla_calculo',v_id_plantilla_calculo::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'CONTA_PLACAL_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		28-08-2013 19:01:20
	***********************************/

	elsif(p_transaccion='CONTA_PLACAL_MOD')then

		begin
			--Sentencia de la modificacion
			update conta.tplantilla_calculo set
			prioridad = v_parametros.prioridad,
			debe_haber = v_parametros.debe_haber,
			tipo_importe = v_parametros.tipo_importe,
			id_plantilla = v_parametros.id_plantilla,
			codigo_tipo_relacion = v_parametros.codigo_tipo_relacion,
			importe = v_parametros.importe,
			descripcion = v_parametros.descripcion,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario
			where id_plantilla_calculo=v_parametros.id_plantilla_calculo;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Plantilla de Cálculo modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_plantilla_calculo',v_parametros.id_plantilla_calculo::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'CONTA_PLACAL_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		28-08-2013 19:01:20
	***********************************/

	elsif(p_transaccion='CONTA_PLACAL_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from conta.tplantilla_calculo
            where id_plantilla_calculo=v_parametros.id_plantilla_calculo;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Plantilla de Cálculo eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_plantilla_calculo',v_parametros.id_plantilla_calculo::varchar);
              
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
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "conta"."ft_plantilla_calculo_ime"(integer, integer, character varying, character varying) OWNER TO postgres;