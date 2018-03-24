<?php
/**
*@package pXP
*@file gen-ACTIntTransaccion.php
*@author  (admin)
*@date 01-09-2013 18:10:12
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/
require_once(dirname(__FILE__).'/../reportes/RTransaccionmayor.php');
require_once(dirname(__FILE__).'/../reportes/RMayorXls.php');
include_once(dirname(__FILE__).'/../../lib/lib_general/ExcelInput.php');

class ACTIntTransaccion extends ACTbase{
			
	function listarIntTransaccion(){
		$this->objParam->defecto('ordenacion','orden');
		$this->objParam->defecto('dir_ordenacion','asc');
		
		if($this->objParam->getParametro('id_int_comprobante')!=''){
			$this->objParam->addFiltro("transa.id_int_comprobante = ".$this->objParam->getParametro('id_int_comprobante'));	
		}
		
		
		if($this->objParam->getParametro('id_int_comprobante_fks')!=''){
			$this->objParam->addFiltro("transa.id_int_comprobante in (".$this->objParam->getParametro('id_int_comprobante_fks').")");	
		}
		else{
			if($this->objParam->getParametro('forzar_relacion')=='si'){
				 throw new Exception("Primero defina con que comprobante esta relacionado", 3);
				 $this->objParam->addFiltro("transa.id_int_comprobante in (0)");	
		
			}
		}
		
		if($this->objParam->getParametro('solo_debe')=='si'){
			$this->objParam->addFiltro("transa.importe_debe > 0 ");	
		}
		
		if($this->objParam->getParametro('solo_haber')=='si'){
			$this->objParam->addFiltro("transa.importe_haber > 0 ");	
		}
		
		if($this->objParam->getParametro('solo_gasto_recurso') == 'si'){
			$this->objParam->addFiltro("par.tipo in (''recurso'',''gasto'')");	
		}
		
		if($this->objParam->getParametro('pres_gasto_recurso') == 'si'){
			$this->objParam->addFiltro("cc.movimiento_tipo_pres in (''gasto'',''recurso'')");	
		}

         if($this->objParam->getParametro('pres_adm') == 'si'){
			$this->objParam->addFiltro("cc.movimiento_tipo_pres in (''administrativo'')");	
		}

		
		
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODIntTransaccion','listarIntTransaccion');
		} else{
			$this->objFunc=$this->create('MODIntTransaccion');
			
			$this->res=$this->objFunc->listarIntTransaccion($this->objParam);
		}
		
		if($this->objParam->getParametro('resumen')!='no'){
			//adicionar una fila al resultado con el summario
			$temp = Array();
			$temp['importe_debe'] = $this->res->extraData['total_debe'];
			$temp['importe_haber'] = $this->res->extraData['total_haber'];
			$temp['importe_debe_mb'] = $this->res->extraData['total_debe_mb'];
			$temp['importe_haber_mb'] = $this->res->extraData['total_haber_mb'];
			$temp['importe_debe_mt'] = $this->res->extraData['total_debe_mt'];
			$temp['importe_haber_mt'] = $this->res->extraData['total_haber_mt'];			
			$temp['importe_debe_ma'] = $this->res->extraData['total_debe_ma'];
			$temp['importe_haber_ma'] = $this->res->extraData['total_haber_ma'];
			$temp['importe_gasto'] = $this->res->extraData['total_gasto'];
			$temp['importe_recurso'] = $this->res->extraData['total_recurso'];
			$temp['glosa'] = 'Sumas iguales';
			$temp['tipo_reg'] = 'summary';
			$temp['id_int_transaccion'] = 0;
			
			$this->res->total++;
			
			$this->res->addLastRecDatos($temp);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarIntTransaccion(){
		$this->objFunc=$this->create('MODIntTransaccion');	
		if($this->objParam->insertar('id_int_transaccion')){
			$this->res=$this->objFunc->insertarIntTransaccion($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarIntTransaccion($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarIntTransaccion(){
			$this->objFunc=$this->create('MODIntTransaccion');	
		$this->res=$this->objFunc->eliminarIntTransaccion($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	
	function listarIntTransaccionMayor(){
		$this->objParam->defecto('ordenacion','id_int_transaccion');
		$this->objParam->defecto('dir_ordenacion','asc');
		
		if($this->objParam->getParametro('id_int_comprobante')!=''){
			$this->objParam->addFiltro("transa.id_int_comprobante = ".$this->objParam->getParametro('id_int_comprobante'));	
		}
		
		
		if($this->objParam->getParametro('id_gestion')!=''){
			$this->objParam->addFiltro("per.id_gestion = ".$this->objParam->getParametro('id_gestion'));	
		}
		
		if($this->objParam->getParametro('id_config_tipo_cuenta')!=''){
			$this->objParam->addFiltro("ctc.id_config_tipo_cuenta = ".$this->objParam->getParametro('id_config_tipo_cuenta'));	
		}
		
		if($this->objParam->getParametro('id_config_subtipo_cuenta')!=''){
			$this->objParam->addFiltro("csc.id_config_subtipo_cuenta = ".$this->objParam->getParametro('id_config_subtipo_cuenta'));	
		}
		
		
		if($this->objParam->getParametro('id_depto')!=''){
			$this->objParam->addFiltro("icbte.id_depto = ".$this->objParam->getParametro('id_depto'));	
		}
		
		
		 
		if($this->objParam->getParametro('id_partida')!=''){
			$this->objParam->addFiltro("transa.id_partida = ".$this->objParam->getParametro('id_partida'));	
		}
		
		if($this->objParam->getParametro('id_suborden')!=''){
			$this->objParam->addFiltro("transa.id_subordeno = ".$this->objParam->getParametro('id_suborden'));	
		}
		
		
		if($this->objParam->getParametro('id_auxiliar')!=''){
			$this->objParam->addFiltro("transa.id_auxiliar = ".$this->objParam->getParametro('id_auxiliar'));	
		}
		
		if($this->objParam->getParametro('id_centro_costo')!=''){
			$this->objParam->addFiltro("transa.id_centro_costo = ".$this->objParam->getParametro('id_centro_costo'));	
		}
		
		if($this->objParam->getParametro('nro_tramite')!=''){
			$this->objParam->addFiltro("icbte.nro_tramite ilike ''%".$this->objParam->getParametro('nro_tramite')."%''");	
		}

        if($this->objParam->getParametro('desde')!='' && $this->objParam->getParametro('hasta')!=''){
			$this->objParam->addFiltro("(icbte.fecha::date  BETWEEN ''%".$this->objParam->getParametro('desde')."%''::date  and ''%".$this->objParam->getParametro('hasta')."%''::date)");	
		}
		
		if($this->objParam->getParametro('desde')!='' && $this->objParam->getParametro('hasta')==''){
			$this->objParam->addFiltro("(icbte.fecha::date  >= ''%".$this->objParam->getParametro('desde')."%''::date)");	
		}
		
		if($this->objParam->getParametro('desde')=='' && $this->objParam->getParametro('hasta')!=''){
			$this->objParam->addFiltro("(icbte.fecha::date  <= ''%".$this->objParam->getParametro('hasta')."%''::date)");	
		}

		
		
		
		
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODIntTransaccion','listarIntTransaccionMayor');
		} else{
			$this->objFunc=$this->create('MODIntTransaccion');
			
			$this->res=$this->objFunc->listarIntTransaccionMayor($this->objParam);
		}
		//adicionar una fila al resultado con el summario
		$temp = Array();
		$temp['importe_debe_mb'] = $this->res->extraData['total_debe'];
		$temp['importe_haber_mb'] = $this->res->extraData['total_haber'];
		$temp['importe_debe_mt'] = $this->res->extraData['total_debe_mt'];
		$temp['importe_haber_mt'] = $this->res->extraData['total_haber_mt'];		
		$temp['importe_debe_ma'] = $this->res->extraData['total_debe_ma'];
		$temp['importe_haber_ma'] = $this->res->extraData['total_haber_ma'];
		$temp['tipo_reg'] = 'summary';
		$temp['id_int_transaccion'] = 0;
		
		$this->res->total++;
		
		$this->res->addLastRecDatos($temp);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

    function guardarDatosBancos(){
		$this->objFunc=$this->create('MODIntTransaccion');	
		if($this->objParam->insertar('id_int_transaccion')){
			$this->res=$this->objFunc->guardarDatosBancos($this->objParam);			
		} else{			
			$this->res=$this->objFunc->guardarDatosBancos($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

     function listarIntTransaccionOrden(){
		$this->objParam->defecto('ordenacion','id_orden_trabajo');
		$this->objParam->defecto('dir_ordenacion','asc');
		
		
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODIntTransaccion','listarIntTransaccionOrden');
		} else{
			$this->objFunc=$this->create('MODIntTransaccion');
			
			$this->res=$this->objFunc->listarIntTransaccionOrden($this->objParam);
		}
		//adicionar una fila al resultado con el summario
		$temp = Array();
		$temp['importe_debe_mb'] = $this->res->extraData['total_debe'];
		$temp['importe_haber_mb'] = $this->res->extraData['total_haber'];
		$temp['importe_debe_mt'] = $this->res->extraData['total_debe_mt'];
		$temp['importe_haber_mt'] = $this->res->extraData['total_haber_mt'];
		$temp['importe_debe_ma'] = $this->res->extraData['total_debe_ma'];
		$temp['importe_haber_ma'] = $this->res->extraData['total_haber_ma'];
		$temp['tipo_reg'] = 'summary';
		$temp['id_orden_trabajo'] = -1;
		
		$this->res->total++;
		
		$this->res->addLastRecDatos($temp);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

    function listarIntTransaccionPartida(){
		$this->objParam->defecto('ordenacion','codigo_partida');
		$this->objParam->defecto('dir_ordenacion','asc');
		
		
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODIntTransaccion','listarIntTransaccionPartida');
		} else{
			$this->objFunc=$this->create('MODIntTransaccion');
			
			$this->res=$this->objFunc->listarIntTransaccionPartida($this->objParam);
		}
		//adicionar una fila al resultado con el summario
		$temp = Array();
		$temp['importe_debe_mb'] = $this->res->extraData['total_debe'];
		$temp['importe_haber_mb'] = $this->res->extraData['total_haber'];
		$temp['importe_debe_mt'] = $this->res->extraData['total_debe_mt'];
		$temp['importe_haber_mt'] = $this->res->extraData['total_haber_mt'];
		$temp['importe_debe_ma'] = $this->res->extraData['total_debe_ma'];
		$temp['importe_haber_ma'] = $this->res->extraData['total_haber_ma'];
		$temp['tipo_reg'] = 'summary';
		$temp['tipo_reg'] = 'summary';
		$temp['id_partida'] = -1;
		
		$this->res->total++;
		
		$this->res->addLastRecDatos($temp);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

    function listarIntTransaccionCuenta(){
		$this->objParam->defecto('ordenacion','codigo_partida');
		$this->objParam->defecto('dir_ordenacion','asc');
		
		
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODIntTransaccion','listarIntTransaccionCuenta');
		} else{
			$this->objFunc=$this->create('MODIntTransaccion');
			
			$this->res=$this->objFunc->listarIntTransaccionCuenta($this->objParam);
		}
		//adicionar una fila al resultado con el summario
		$temp = Array();
		$temp['importe_debe_mb'] = $this->res->extraData['total_debe'];
		$temp['importe_haber_mb'] = $this->res->extraData['total_haber'];
		$temp['importe_debe_mt'] = $this->res->extraData['total_debe_mt'];
		$temp['importe_haber_mt'] = $this->res->extraData['total_haber_mt'];
		$temp['importe_debe_ma'] = $this->res->extraData['total_debe_ma'];
		$temp['importe_haber_ma'] = $this->res->extraData['total_haber_ma'];
		$temp['tipo_reg'] = 'summary';
		$temp['id_cuenta'] = -1;
		
		$this->res->total++;
		
		$this->res->addLastRecDatos($temp);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	//
	function listarIntTransaccionMayorReporte(){		
		if($this->objParam->getParametro('id_int_comprobante')!=''){
			$this->objParam->addFiltro("transa.id_int_comprobante = ".$this->objParam->getParametro('id_int_comprobante'));	
		}
		if($this->objParam->getParametro('id_gestion')!=''){
			$this->objParam->addFiltro("per.id_gestion = ".$this->objParam->getParametro('id_gestion'));	
		}		
		if($this->objParam->getParametro('id_config_tipo_cuenta')!=''){
			$this->objParam->addFiltro("ctc.id_config_tipo_cuenta = ".$this->objParam->getParametro('id_config_tipo_cuenta'));	
		}		
		if($this->objParam->getParametro('id_config_subtipo_cuenta')!=''){
			$this->objParam->addFiltro("csc.id_config_subtipo_cuenta = ".$this->objParam->getParametro('id_config_subtipo_cuenta'));	
		}
		if($this->objParam->getParametro('id_depto')!=''){
			$this->objParam->addFiltro("icbte.id_depto = ".$this->objParam->getParametro('id_depto'));	
		}	
		if($this->objParam->getParametro('id_partida')!=''){
			$this->objParam->addFiltro("transa.id_partida = ".$this->objParam->getParametro('id_partida'));	
		}		
		if($this->objParam->getParametro('id_suborden')!=''){
			$this->objParam->addFiltro("transa.id_subordeno = ".$this->objParam->getParametro('id_suborden'));	
		}
		if($this->objParam->getParametro('id_auxiliar')!=''){
			$this->objParam->addFiltro("transa.id_auxiliar = ".$this->objParam->getParametro('id_auxiliar'));	
		}		
		if($this->objParam->getParametro('id_centro_costo')!=''){
			$this->objParam->addFiltro("transa.id_centro_costo = ".$this->objParam->getParametro('id_centro_costo'));	
		}		
		if($this->objParam->getParametro('nro_tramite')!=''){
			$this->objParam->addFiltro("icbte.nro_tramite ilike ''%".$this->objParam->getParametro('nro_tramite')."%''");	
		}
		if($this->objParam->getParametro('desde')!='' && $this->objParam->getParametro('hasta')!=''){
			$this->objParam->addFiltro("(icbte.fecha::date  BETWEEN ''%".$this->objParam->getParametro('desde')."%''::date  and ''%".$this->objParam->getParametro('hasta')."%''::date)");	
		}		
		if($this->objParam->getParametro('desde')!='' && $this->objParam->getParametro('hasta')==''){
			$this->objParam->addFiltro("(icbte.fecha::date  >= ''%".$this->objParam->getParametro('desde')."%''::date)");	
		}		
		if($this->objParam->getParametro('desde')=='' && $this->objParam->getParametro('hasta')!=''){
			$this->objParam->addFiltro("(icbte.fecha::date  <= ''%".$this->objParam->getParametro('hasta')."%''::date)");	
		}
		$this->objFunc=$this->create('MODIntTransaccion');								
		$cbteHeader = $this->objFunc->listarIntTransaccionRepMayor($this->objParam);
				
		if($cbteHeader->getTipo() == 'EXITO'){										
			return $cbteHeader;			
		}
		else{
			$cbteHeader->imprimirRespuesta($cbteHeader->generarJson());
			exit;
		}		
	}	
	//mp
	function impReporteMayor() {
		if($this->objParam->getParametro('tipo_formato')=='pdf') {
			$nombreArchivo = uniqid(md5(session_id()).'LibroMayor').'.pdf';			
			$dataSource = $this->listarIntTransaccionMayorReporte();
			$dataEntidad = "";
			$dataPeriodo = "";	
			$orientacion = 'P';		
			$tamano = 'LETTER';
			$titulo = 'Consolidado';
			$this->objParam->addParametro('orientacion',$orientacion);
			$this->objParam->addParametro('tamano',$tamano);		
			$this->objParam->addParametro('titulo_archivo',$titulo);	
			$this->objParam->addParametro('nombre_archivo',$nombreArchivo);
			$reporte = new RTransaccionmayor($this->objParam);  
			$reporte->datosHeader($dataSource->getDatos(),$dataSource->extraData, '' , '');		
			$reporte->generarReporte();
			$reporte->output($reporte->url_archivo,'F');
			$this->mensajeExito=new Mensaje();
			$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se genera con exito el reporte: '.$nombreArchivo,'control');
			$this->mensajeExito->setArchivoGenerado($nombreArchivo);
			$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());		
		}
		if($this->objParam->getParametro('tipo_formato')=='xls') {				
			$this->objFun=$this->create('MODIntTransaccion');	
			$this->res = $this->objFun->listarIntTransaccionRepMayor();	
			if($this->res->getTipo()=='ERROR'){
				$this->res->imprimirRespuesta($this->res->generarJson());
				exit;
			}		
			$titulo ='Ret';
			$nombreArchivo=uniqid(md5(session_id()).$titulo);
			$nombreArchivo.='.xls';
			$this->objParam->addParametro('nombre_archivo',$nombreArchivo);
			$this->objParam->addParametro('datos',$this->res->datos);
						
			$this->objReporteFormato=new RMayorXls($this->objParam);
			$this->objReporteFormato->generarDatos();
			$this->objReporteFormato->generarReporte();
			$this->mensajeExito=new Mensaje();
			$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se genero con éxito el reporte: '.$nombreArchivo,'control');
			$this->mensajeExito->setArchivoGenerado($nombreArchivo);
			$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
		}					
	}

	function SubirArchivoTran(){
        $arregloFiles = $this->objParam->getArregloFiles();
        $ext = pathinfo($arregloFiles['archivo']['name']);
        $extension = $ext['extension'];
        $error = 'no';
        $mensaje_completo = '';
        
        if(isset($arregloFiles['archivo']) && is_uploaded_file($arregloFiles['archivo']['tmp_name'])) {
            if (!in_array($extension, array('xls', 'xlsx', 'XLS', 'XLSX'))) {
                $mensaje_completo = "La extensión del archivo debe ser XLS o XLSX";
                $error = 'error_fatal';
            } else {
                //procesa Archivo
                $archivoExcel = new ExcelInput($arregloFiles['archivo']['tmp_name'], 'IMPTRACON');
                $archivoExcel->recuperarColumnasExcel();
                $arrayArchivo = $archivoExcel->leerColumnasArchivoExcel();
                foreach ($arrayArchivo as $fila) {
                	//var_dump($fila)	;echo"<br>";				
                    $this->objParam->addParametro('centro_costo', $fila['centro_costo']);
                    $this->objParam->addParametro('partida', $fila['partida']);
                    $this->objParam->addParametro('cuenta', $fila['cuenta']);
                    $this->objParam->addParametro('auxiliar', $fila['auxiliar']);
                    $this->objParam->addParametro('orden', $fila['orden']);
                    $this->objParam->addParametro('suborden', $fila['suborden']);                  
                    $this->objParam->addParametro('debe', $fila['debe']);
                    $this->objParam->addParametro('haber', $fila['haber']);
					$this->objParam->addParametro('glosa', $fila['glosa']);
                    
                    $this->objFunc = $this->create('MODIntTransaccion');
                    $this->res = $this->objFunc->insertarIntTransaccionXLS($this->objParam);
                   
                    if ($this->res->getTipo() == 'ERROR') {
                    	
						$this->res->imprimirRespuesta($this->res->generarJson());
			            exit;
						
                        $error = 'error';
                        $mensaje_completo = "Error al guardar el fila en tabla :  " . $this->res->getMensajeTec();
                        break;
                    }
                }
            }
        } else {
            $mensaje_completo = "No se subio el archivo";
            $error = 'error_fatal';
        }
        
		

        if ($error == 'error_fatal') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('ERROR','ACTIntTransaccion.php',$mensaje_completo,
                $mensaje_completo,'control');
            //si no es error fatal proceso el archivo
        }

        if ($error == 'error') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('ERROR','ACTIntTransaccion.php','Ocurrieron los siguientes errores : ' . $mensaje_completo,
                $mensaje_completo,'control');

        } else if ($error == 'no') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('EXITO','ACTIntTransaccion.php','El archivo fue ejecutado con éxito',
                'El archivo fue ejecutado con éxito','control');
        }

        //devolver respuesta
        $this->mensajeRes->imprimirRespuesta($this->mensajeRes->generarJson());
    }

		
}

?>