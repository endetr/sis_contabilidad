CREATE OR REPLACE FUNCTION conta.f_import_tdetalle_plantilla_comprobante (
  p_accion varchar,
  p_codigo_plantilla varchar,
  p_codigo varchar,
  p_debe_haber varchar,
  p_agrupar varchar,
  p_es_relacion_contable varchar,
  p_campo_partida varchar,
  p_campo_concepto_transaccion varchar,
  p_tipo_relacion_contable varchar,
  p_campo_cuenta varchar,
  p_campo_monto varchar,
  p_campo_relacion_contable varchar,
  p_campo_documento varchar,
  p_aplicar_documento varchar,
  p_campo_centro_costo varchar,
  p_campo_auxiliar varchar,
  p_campo_fecha varchar,
  p_primaria varchar,
  p_otros_campos varchar,
  p_nom_fk_tabla_maestro varchar,
  p_campo_partida_ejecucion varchar,
  p_descripcion varchar,
  p_campo_monto_pres varchar,
  p_id_detalle_plantilla_fk varchar,
  p_forma_calculo_monto varchar,
  p_func_act_transaccion varchar,
  p_campo_id_tabla_detalle varchar,
  p_rel_dev_pago varchar,
  p_campo_trasaccion_dev varchar,
  p_campo_id_cuenta_bancaria varchar,
  p_campo_id_cuenta_bancaria_mov varchar,
  p_campo_nro_cheque varchar,
  p_campo_nro_cuenta_bancaria_trans varchar,
  p_campo_porc_monto_excento_var varchar,
  p_campo_nombre_cheque_trans varchar,
  p_prioridad_documento varchar,
  p_campo_orden_trabajo varchar,
  p_tabla_detalle varchar,
  p_codigo_fk varchar,
  p_campo_forma_pago varchar,
  p_tipo_relacion_contable_cc varchar = ''::character varying,
  p_campo_relacion_contable_cc varchar = ''::character varying,
  p_campo_suborden varchar = ''::character varying,
  p_incluir_desc_doc varchar = ''::character varying,
  p_campo_codigo_aplicacion_rc varchar = ''::character varying,
  p_procesar_prioridad_principal varchar = ''::character varying
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Contabilidad
 FUNCION: 		conta.f_import_tdetalle_plantilla_comprobante
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'conta.f_import_tdetalle_plantilla_comprobante'
 AUTOR: 		 (admin)
 FECHA:	        11/01/2019
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:
 ISSUE 		  		 FECHA   			 AUTOR				    DESCRIPCION:
 # 21 ENDETRASM	 	11/01/2019			Miguel Mamani			Modificar generador de comprobantes para considerar la división de descuentos entre comprobantes de pago y diario
 #31  EndeETR       06/02/2019          EGS                     Se agrega el campo campo_codigo_aplicacion_rc en el exportador de plantilla
 #42  EndeETR       02/04/2019           EGS                    Se agrega el campo procesar_prioridad_principal en el exportador de plantilla

***************************************************************************/

DECLARE

    v_id_plantilla_comprobante		integer;
    v_id_detalle_plantilla_comprobante	integer;
    v_id_detalle_plantilla_comprobante_fk	integer;
BEGIN



    select id_plantilla_comprobante into v_id_plantilla_comprobante
    from conta.tplantilla_comprobante pc
    where trim(lower(pc.codigo)) = trim(lower(p_codigo_plantilla));


    select id_detalle_plantilla_comprobante into v_id_detalle_plantilla_comprobante
    from conta.tdetalle_plantilla_comprobante dpc
    where trim(lower(dpc.codigo)) = trim(lower(p_codigo))
          and id_plantilla_comprobante = v_id_plantilla_comprobante;



  select id_detalle_plantilla_comprobante into v_id_detalle_plantilla_comprobante_fk
    from conta.tdetalle_plantilla_comprobante dpc
    where trim(lower(dpc.codigo)) = trim(lower(p_codigo_fk))
          and id_plantilla_comprobante = v_id_plantilla_comprobante;




    if (p_accion = 'delete') then

        update conta.tdetalle_plantilla_comprobante set estado_reg = 'inactivo'
    	where id_detalle_plantilla_comprobante = v_id_detalle_plantilla_comprobante;

    else
        if (v_id_detalle_plantilla_comprobante is null)then

            --Sentencia de la insercion
        	insert into conta.tdetalle_plantilla_comprobante(
                id_plantilla_comprobante,
                debe_haber,
                agrupar,
                es_relacion_contable,
                tabla_detalle,
                campo_partida,
                campo_concepto_transaccion,
                tipo_relacion_contable,
                campo_cuenta,
                campo_monto,
                campo_relacion_contable,
                campo_documento,
                aplicar_documento,
                campo_centro_costo,
                campo_auxiliar,
                campo_fecha,
                estado_reg,
                fecha_reg,
                id_usuario_reg,
                fecha_mod,
                id_usuario_mod,
                primaria,
                otros_campos,
                nom_fk_tabla_maestro,
                campo_partida_ejecucion ,
                descripcion ,
                campo_monto_pres ,
                id_detalle_plantilla_fk ,
                forma_calculo_monto,
                func_act_transaccion,
                campo_id_tabla_detalle,
                rel_dev_pago,
                campo_trasaccion_dev,
                campo_id_cuenta_bancaria,
                campo_id_cuenta_bancaria_mov,
                campo_nro_cheque,
                campo_nro_cuenta_bancaria_trans,
                campo_porc_monto_excento_var,
                campo_nombre_cheque_trans,
                prioridad_documento,
                campo_orden_trabajo,
                campo_forma_pago,
                codigo,
                tipo_relacion_contable_cc,
                campo_relacion_contable_cc,
                campo_suborden,
                incluir_desc_doc, --/#21
                campo_codigo_aplicacion_rc, --#31
                procesar_prioridad_principal --#42
          	) values(
                v_id_plantilla_comprobante,
                p_debe_haber,
                p_agrupar,
                p_es_relacion_contable,
                p_tabla_detalle,
                p_campo_partida,
                p_campo_concepto_transaccion,
                p_tipo_relacion_contable,
                p_campo_cuenta,
                p_campo_monto,
                p_campo_relacion_contable,
                p_campo_documento,
                p_aplicar_documento,
                p_campo_centro_costo,
                p_campo_auxiliar,
                p_campo_fecha,
                'activo',
                now(),
                1,
                null,
                null,

                p_primaria,
                p_otros_campos,
                p_nom_fk_tabla_maestro,
                p_campo_partida_ejecucion ,
                p_descripcion ,
                p_campo_monto_pres ,
                v_id_detalle_plantilla_comprobante_fk ,
                p_forma_calculo_monto,
                p_func_act_transaccion,
                p_campo_id_tabla_detalle,
                p_rel_dev_pago,
                p_campo_trasaccion_dev,
                p_campo_id_cuenta_bancaria,
                p_campo_id_cuenta_bancaria_mov,
                p_campo_nro_cheque ,
                p_campo_nro_cuenta_bancaria_trans,
                p_campo_porc_monto_excento_var,
                p_campo_nombre_cheque_trans,
                p_prioridad_documento::INTEGER,
                p_campo_orden_trabajo,
                p_campo_forma_pago,
                p_codigo,
                p_tipo_relacion_contable_cc,
                p_campo_relacion_contable_cc,
                p_campo_suborden,
                p_incluir_desc_doc, --#21
                p_campo_codigo_aplicacion_rc,  --#31
                p_procesar_prioridad_principal --#42
			);


        else
            update conta.tdetalle_plantilla_comprobante set
              id_plantilla_comprobante = v_id_plantilla_comprobante,
              debe_haber = p_debe_haber,
              agrupar = p_agrupar,
              es_relacion_contable = p_es_relacion_contable,
              tabla_detalle = p_tabla_detalle,
              campo_partida = p_campo_partida,
              campo_concepto_transaccion = p_campo_concepto_transaccion,
              tipo_relacion_contable = p_tipo_relacion_contable,
              campo_cuenta = p_campo_cuenta,
              campo_monto = p_campo_monto,
              campo_relacion_contable = p_campo_relacion_contable,
              campo_documento = p_campo_documento,
              aplicar_documento = p_aplicar_documento,
              campo_centro_costo = p_campo_centro_costo,
              campo_auxiliar = p_campo_auxiliar,
              campo_fecha = p_campo_fecha,
              fecha_mod = now(),
              id_usuario_mod = 1,
              primaria=p_primaria,
              otros_campos=p_otros_campos,
              nom_fk_tabla_maestro=p_nom_fk_tabla_maestro,
              campo_partida_ejecucion=p_campo_partida_ejecucion ,
              descripcion=p_descripcion ,
              campo_monto_pres=p_campo_monto_pres ,
              id_detalle_plantilla_fk=v_id_detalle_plantilla_comprobante_fk ,
              forma_calculo_monto=p_forma_calculo_monto,
              func_act_transaccion=p_func_act_transaccion,
              campo_id_tabla_detalle=p_campo_id_tabla_detalle,
              rel_dev_pago=p_rel_dev_pago,
              campo_trasaccion_dev=p_campo_trasaccion_dev,
              campo_id_cuenta_bancaria = p_campo_id_cuenta_bancaria,
              campo_id_cuenta_bancaria_mov = p_campo_id_cuenta_bancaria_mov,
              campo_nro_cheque = p_campo_nro_cheque,
              campo_nro_cuenta_bancaria_trans=p_campo_nro_cuenta_bancaria_trans,
              campo_porc_monto_excento_var=p_campo_porc_monto_excento_var,
              campo_nombre_cheque_trans = p_campo_nombre_cheque_trans,
              prioridad_documento = p_prioridad_documento::INTEGER,
              campo_orden_trabajo = p_campo_orden_trabajo,
              campo_forma_pago = p_campo_forma_pago,
              codigo = p_codigo,
              tipo_relacion_contable_cc = p_tipo_relacion_contable_cc ,
              campo_relacion_contable_cc = p_campo_relacion_contable_cc,
              campo_suborden = p_campo_suborden,
              incluir_desc_doc = p_incluir_desc_doc, --#21
              campo_codigo_aplicacion_rc = p_campo_codigo_aplicacion_rc, --#21
              procesar_prioridad_principal = p_procesar_prioridad_principal --#42
			where id_detalle_plantilla_comprobante=v_id_detalle_plantilla_comprobante;
             
              
                    	
        end if;
    
	end if; 
    
    ALTER TABLE wf.ttipo_proceso ENABLE TRIGGER USER;   
    return 'exito';
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;