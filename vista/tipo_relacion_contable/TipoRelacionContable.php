<?php
/**
*@package pXP
*@file gen-TipoRelacionContable.php
*@author  (admin)
*@date 16-05-2013 21:51:43
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
 ISSUE			FECHA				AUTHOR 			DESCRIPCION
 #14	endeEtr 	04/01/2019			EGS				se agrego el boton para la exportacion de configuracion	
 */

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.TipoRelacionContable=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		//llama al constructor de la clase padre
		Phx.vista.TipoRelacionContable.superclass.constructor.call(this,config);
		this.init();		
		this.iniciarEventos();
		 //#14	04/01/2019	EGS	
		this.addButton('btnWizard',
            {
                text: 'Exportar Plantilla',
                iconCls: 'bchecklist',
                disabled: false,
                handler: this.expProceso,
                tooltip: '<b>Exportar</b><br/>Exporta a archivo SQL la plantilla'
            }
        ); //#14	04/01/2019	EGS	
			
	},
	 //#14	04/01/2019	EGS	
	expProceso : function(resp){
			var data=this.sm.getSelected().data;
			console.log('data',data);
			Phx.CP.loadingShow();
			Ext.Ajax.request({
				url: '../../sis_contabilidad/control/TipoRelacionContable/exportarDatos',
				params: { 'id_tipo_relacion_contable' : data.id_tipo_relacion_contable },
				success: this.successExport,
				failure: this.conexionFailure,
				timeout: this.timeout,
				scope: this
			});
			
	}, //#14	04/01/2019	EGS	
	
	
	tam_pag:50,
			
	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_tipo_relacion_contable'
			},
			type:'Field',
			form:true 
		},
		
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_tabla_relacion_contable'
			},
			type:'Field',
			form:true 
		},
		
		{
			config:{
				name: 'codigo_tipo_relacion',
				fieldLabel: 'Codigo Tipo Relación',
				allowBlank: false,
				anchor: '80%',
				gwidth: 150,
				maxLength:15
			},
			type:'TextField',
			filters:{pfiltro:'tiprelco.codigo_tipo_relacion',type:'string'},
			bottom_filter : true,
			id_grupo:0,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'nombre_tipo_relacion',
				fieldLabel: 'Nombre Tipo Relación',
				allowBlank: false,
				anchor: '80%',
				gwidth: 200,
				maxLength:200
			},
			type:'TextField',
			filters:{pfiltro:'tiprelco.nombre_tipo_relacion',type:'string'},
			bottom_filter : true,
			id_grupo:0,
			grid:true,
			form:true
		},
		{
	       		config:{
	       			name:'tiene_centro_costo',
	       			fieldLabel:'Tiene Centro de Costo',
	       			qtip: '(SI o NO): La configuración de la cuentas puede variar por centro de costos.  (SI-Único):  se utiliza para recuperar el centro de costo  a partir de código del tipo de relación. (Si.- Gen): Sí general,  permite la configuración sea general si el centro de costo no se especifica  (Es igual a una configuración por defecto sin importar el valor del centro de costos, pero si exiten tiene prioridad sobre la general)',
	       			allowBlank:false,
	       			emptyText:'Tiene...',
	       			typeAhead: true,
	       		    triggerAction: 'all',
	       		    lazyRender:true,
	       		    mode: 'local',
	       		    gwidth: 150,
	       		    anchor: '100%',
	       		    store:new Ext.data.ArrayStore({
		        	fields: ['ID', 'valor'],
		        	data :	[['si','Si'],	
		        			['no','No'],
		        			['si-unico','Si-Unico, solo permite centro de costo'],
		        			['si-general','Si-Gen, permitir configuración general cuando el centor de costo es vacio']]
		        				
		    		}),
					valueField:'ID',
					displayField:'valor',
	       		},
	       		type:'ComboBox',
	       		id_grupo:0,
	       		grid:true,
	       		form:true
	       	},	
		{
			config:{
				name: 'estado_reg',
				fieldLabel: 'Estado Reg.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:10
			},
			type:'TextField',
			filters:{pfiltro:'tiprelco.estado_reg',type:'string'},
			id_grupo:0,
			grid:true,
			form:false
		},
		
		{
			config:{
				name: 'fecha_reg',
				fieldLabel: 'Fecha creación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
						format: 'd/m/Y', 
						renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
			type:'DateField',
			filters:{pfiltro:'tiprelco.fecha_reg',type:'date'},
			id_grupo:0,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'usr_reg',
				fieldLabel: 'Creado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
			type:'NumberField',
			filters:{pfiltro:'usu1.cuenta',type:'string'},
			id_grupo:0,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'fecha_mod',
				fieldLabel: 'Fecha Modif.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
						format: 'd/m/Y', 
						renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
			type:'DateField',
			filters:{pfiltro:'tiprelco.fecha_mod',type:'date'},
			id_grupo:0,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'usr_mod',
				fieldLabel: 'Modificado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
			type:'NumberField',
			filters:{pfiltro:'usu2.cuenta',type:'string'},
			id_grupo:0,
			grid:true,
			form:false
		},
		{
	       		config:{
	       			name:'tiene_partida',
	       			fieldLabel:'Tiene Partida',
	       			allowBlank:false,
	       			emptyText:'Tiene...',
	       			typeAhead: true,
	       		    triggerAction: 'all',
	       		    lazyRender:true,
	       		    mode: 'local',
	       		    gwidth: 100,
	       		    store:['si','no']
	       		},
	       		type:'ComboBox',
	       		id_grupo:1,
	       		grid:true,
	       		form:true
	      },
	      {
			config: {
				name: 'partida_tipo',
				fieldLabel: 'Tipo Partida',
				anchor: '100%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				gdisplayField: 'partida_tipo',
				gwidth: 100,
				baseParams:{
						cod_subsistema:'CONTA',
						catalogo_tipo:'tttipo_relacion_contable__partida_tipo'
				},
				renderer:function (value, p, record){return String.format('{0}', record.data['partida_tipo']);}
			},
			type: 'ComboRec',
			id_grupo: 1,
			filters:{pfiltro:'tiprelco.partida_tipo',type:'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'partida_rubro',
				fieldLabel: 'Rubro',
				anchor: '100%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				gdisplayField: 'partida_rubro',
				gwidth: 100,
				baseParams:{
						cod_subsistema:'CONTA',
						catalogo_tipo:'tttipo_relacion_contable__partida_rubro'
				},
				renderer:function (value, p, record){return String.format('{0}', record.data['partida_rubro']);}
			},
			type: 'ComboRec',
			id_grupo: 1,
			filters:{pfiltro:'tiprelco.partida_rubro',type:'string'},
			grid: true,
			form: true
		},
	      {
	       		config:{
	       			name:'tiene_auxiliar',
	       			fieldLabel:'Tiene Auxiliar',
	       			qtip: ' (SI o NO) Si tiene o no  que especificar el auxiliar contable. (Dinámico) en caso de ser dinámico,   estos valores  ID AUXILIAR o CÓDIGO AUXILIAR tiene que estar registros en el Maestro ',
	       			allowBlank:false,
	       			emptyText:'Tiene...',
	       			typeAhead: true,
	       		    triggerAction: 'all',
	       		    lazyRender:true,
	       		    mode: 'local',
	       		    gwidth: 100,
	       		    store:['si','no','dinamico']
	       		},
	       		type:'ComboBox',
	       		id_grupo:0,
	       		grid:true,
	       		form:true
	       	},
	      {
	       		config:{
	       			name:'tiene_moneda',
	       			fieldLabel:'Considerar Moneda',
	       			qtip: ' (SI o NO) en función de la moenda del cbte podemos escoger una relacion contable u otra (Ejm  proveedores por pagar)',
	       			allowBlank:false,
	       			emptyText:'Tiene...',
	       			typeAhead: true,
	       		    triggerAction: 'all',
	       		    lazyRender:true,
	       		    mode: 'local',
	       		    gwidth: 100,
	       		    store:['si','no']
	       		},
	       		type:'ComboBox',
	       		id_grupo:0,
	       		grid:true,
	       		form:true
	       	},
	      {
	       		config:{
	       			name:'tiene_tipo_centro',
	       			fieldLabel:'Cinsiderar el Tipo de presupuesto',
	       			qtip: ' (SI o NO) condeirara el tipod e presupeusto: gasto, inversion, recurso etc. (Por ejemplo un concepto de gasto  no usara la misma relacion contable para un proyecto de inversión que para un gasto general) ',
	       			allowBlank:false,
	       			emptyText:'Tiene...',
	       			typeAhead: true,
	       		    triggerAction: 'all',
	       		    lazyRender:true,
	       		    mode: 'local',
	       		    gwidth: 100,
	       		    store:['si','no']
	       		},
	       		type:'ComboBox',
	       		id_grupo:0,
	       		grid:true,
	       		form:true
	       	},
	        {
	       		config:{
	       			name:'tiene_aplicacion',
	       			fieldLabel:'Considerar aplicación',
	       			qtip: ' (SI o NO) La aplicaciones son criterios variables configurables en un catalo para la selacion de relaciones contables, si el valor es si configure tambien la relacion contable a utilizar',
	       			allowBlank:false,
	       			emptyText:'Tiene...',
	       			typeAhead: true,
	       		    triggerAction: 'all',
	       		    lazyRender:true,
	       		    mode: 'local',
	       		    gwidth: 100,
	       		    store:['si','no']
	       		},
	       		type:'ComboBox',
	       		id_grupo:0,
	       		grid:true,
	       		form:true
	       	},
	       	{
				config: {
					typeAhead: false,
					forceSelection: false,
					name: 'codigo_aplicacion_catalogo',
					fieldLabel: 'Tipo Catálogo',
					allowBlank: true,
					emptyText: 'Tipo Catálogo',
					store: new Ext.data.JsonStore({
						url: '../../sis_parametros/control/CatalogoTipo/listarCatalogoTipo',
						id: 'id_catalogo_tipo',
						root: 'datos',
						sortInfo: {
							field: 'nombre',
							direction: 'ASC'
						},
						totalProperty: 'total',
						fields: ['id_catalogo_tipo', 'nombre'],
						// turn on remote sorting
						remoteSort: true,
						baseParams: {
							par_filtro: 'pacati.nombre' //#12
						}
					}),
					valueField: 'nombre',
					displayField: 'nombre',
					gdisplayField: 'desc_catalogo_tipo',
					triggerAction: 'all',
					lazyRender: true,
					mode: 'remote',
					pageSize: 10,
					queryDelay: 200,
					width: 250,
					minChars: 2,
					tpl: '<tpl for="."><div class="x-combo-list-item"><p>{nombre}</p></div></tpl>',
					renderer:function(value, p, record){return String.format('{0}', record.data['codigo_aplicacion_catalogo']);},
					gwidth:130
				},
				type: 'ComboBox',
				id_grupo: 0,
				filters: {
					pfiltro: 'codigo_aplicacion_catalogo',
					type: 'string'
				},
				grid: true,
				form: true
			}
	],
	
	title:'Tipo Relacion Contable',
	ActSave:'../../sis_contabilidad/control/TipoRelacionContable/insertarTipoRelacionContable',
	ActDel:'../../sis_contabilidad/control/TipoRelacionContable/eliminarTipoRelacionContable',
	ActList:'../../sis_contabilidad/control/TipoRelacionContable/listarTipoRelacionContable',
	id_store:'id_tipo_relacion_contable',
	fields: [
		{name:'id_tipo_relacion_contable', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'nombre_tipo_relacion', type: 'string'},
		{name:'tiene_centro_costo', type: 'string'},
		{name:'tiene_partida', type: 'string'},
		{name:'tiene_auxiliar', type: 'string'},
		{name:'codigo_tipo_relacion', type: 'string'},
		{name:'id_tabla_relacion_contable', type: 'numeric'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'partida_tipo', type: 'string'},
		{name:'partida_rubro', type: 'string'},  'tiene_aplicacion', 'tiene_moneda', 'tiene_tipo_centro','codigo_aplicacion_catalogo'
	],
	sortInfo:{
		field: 'id_tipo_relacion_contable',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true,
	Grupos:[{ 
		layout: 'column',
		items:[
			{
				xtype:'fieldset',
				layout: 'form',
                border: true,
                title: 'Datos Generales',
                bodyStyle: 'padding:0 10px 0;',
                columnWidth: 0.5,
                items:[],
		        id_grupo:0,
		        collapsible:true
			},
			{
				xtype:'fieldset',
				layout: 'form',
                border: true,
                title: 'Partida Presupuestaria',
                bodyStyle: 'padding:0 10px 0;',
                columnWidth: 0.5,
                items:[],
		        id_grupo:1,
		        collapsible:true,
		        collapsed:false
			}
			]
	}],
	iniciarEventos: function() {
		this.Cmp.tiene_partida.on('select', function(cmb,rec,val){
			if(cmb.getValue()=='si'){
				this.Cmp.partida_tipo.enable();
				this.setAllowBlank(this.Cmp.partida_tipo, false);
				this.Cmp.partida_rubro.enable();
				this.setAllowBlank(this.Cmp.partida_rubro, false);
				
			} else{
				this.Cmp.partida_tipo.disable();
				this.Cmp.partida_tipo.setValue('');
				this.setAllowBlank(this.Cmp.partida_tipo, true);
				this.Cmp.partida_rubro.disable();
				this.Cmp.partida_rubro.setValue('');
				this.setAllowBlank(this.Cmp.partida_rubro, true);
			}

		},this);
	},
	 //#14	04/01/2019	EGS	  
   	preparaMenu: function(n) {

		var data = this.getSelectedData();
		var tb = this.tbar;
		Phx.vista.TipoRelacionContable.superclass.preparaMenu.call(this, n);
        
		this.getBoton('btnWizard').enable();

		return tb
	},
	
	liberaMenu: function() {
		var tb = Phx.vista.TipoRelacionContable.superclass.liberaMenu.call(this);
		if (tb) {
			this.getBoton('btnWizard').disable();
			           
           
		}
		return tb
	},	//#14	04/01/2019	EGS	
})
</script>
		
		