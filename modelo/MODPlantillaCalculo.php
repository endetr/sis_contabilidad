<?php
/**
*@package pXP
*@file gen-MODPlantillaCalculo.php
*@author  (admin)
*@date 28-08-2013 19:01:20
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODPlantillaCalculo extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarPlantillaCalculo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='conta.ft_plantilla_calculo_sel';
		$this->transaccion='CONTA_PLACAL_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_plantilla_calculo','int4');
		$this->captura('prioridad','int4');
		$this->captura('debe_haber','varchar');
		$this->captura('tipo_importe','varchar');
		$this->captura('id_plantilla','int4');
		$this->captura('codigo_tipo_relacion','varchar');
		$this->captura('importe','numeric');
		$this->captura('descripcion','varchar');
		$this->captura('estado_reg','varchar');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('fecha_mod','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarPlantillaCalculo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='conta.ft_plantilla_calculo_ime';
		$this->transaccion='CONTA_PLACAL_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('prioridad','prioridad','int4');
		$this->setParametro('debe_haber','debe_haber','varchar');
		$this->setParametro('tipo_importe','tipo_importe','varchar');
		$this->setParametro('id_plantilla','id_plantilla','int4');
		$this->setParametro('codigo_tipo_relacion','codigo_tipo_relacion','varchar');
		$this->setParametro('importe','importe','numeric');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarPlantillaCalculo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='conta.ft_plantilla_calculo_ime';
		$this->transaccion='CONTA_PLACAL_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_plantilla_calculo','id_plantilla_calculo','int4');
		$this->setParametro('prioridad','prioridad','int4');
		$this->setParametro('debe_haber','debe_haber','varchar');
		$this->setParametro('tipo_importe','tipo_importe','varchar');
		$this->setParametro('id_plantilla','id_plantilla','int4');
		$this->setParametro('codigo_tipo_relacion','codigo_tipo_relacion','varchar');
		$this->setParametro('importe','importe','numeric');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarPlantillaCalculo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='conta.ft_plantilla_calculo_ime';
		$this->transaccion='CONTA_PLACAL_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_plantilla_calculo','id_plantilla_calculo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>