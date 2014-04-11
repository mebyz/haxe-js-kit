package util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

class Mongoose {

	inline static var INSTANCE_MEMBER_ERROR = "Instance members are not supported";

	#if !macro macro #end public static function buildModel( modelType : Expr ){

		// retrieve class type
		var modelClass = switch( Context.typeExpr(modelType).expr ){
			case TTypeExpr(TClassDecl(c)) :
				c.get();
			default : throw "error";
		}

		var fields = Context.getBuildFields();
		var cl = Context.getLocalClass().get();
		var pos = Context.currentPos();
		var type = Context.getLocalType();
		
		// find Model in superclasses
		var superClass = cl.superClass;
		while( superClass != null ){
			var superType = superClass.t.get();

			if( superType.name == modelClass.name && superType.module == modelClass.module ){
				break;
			}

			superClass = superClass.t.get().superClass;
		}

		// forbid instance members
		for( f in fields ){
			if( f.access.indexOf(AStatic) < 0 ){
				haxe.macro.Context.error( INSTANCE_MEMBER_ERROR , cl.pos );
			}
		}

		var modelDecl = haxe.macro.TypeTools.follow( superClass.params[0] );

		switch(modelDecl){
			case TAnonymous( a ):
				// copy anonymous fields to instance fields
				for( f in a.get().fields ){
					var access = [APublic];
					var varType = haxe.macro.TypeTools.toComplexType( f.type );
					if( f.meta.has(":optional") ){
						varType = TPath({
							sub : null,
							params : [TPType(varType)],
							pack : [],
							name : "Null"
						});
					}
					
					fields.push({
						name : f.name,
						pos : pos,
						meta : f.meta.get(),
						doc : null,
						access : access,
						kind : FVar( varType )
					});
					
				}

				var schemaDef = {
					expr : anonTypeToSchemaDef( a.get() ),
					pos : pos
				};
				
				// add "make" method
				fields.push({
					pos : pos,
					name : 'build',
					meta : [],
					doc : null,
					kind : FFun({
						ret : TPath({
							name : "Model",
							pack : ["js","npm","mongoose"],
							params : [
								TPType( haxe.macro.TypeTools.toComplexType( modelDecl ) ),
								TPType(TPath({
									sub : null,
									params : [],
									pack : cl.pack,
									name : cl.name
								}))
							],
							sub : "TModels"
						}),
						params : [],
						expr : macro {
							
							var s = new js.npm.mongoose.Schema($schemaDef);
							//untyped s.methods = $methodsObj;
							return mongoose.model( name , s , collectionName , skipInit );

						},
						args : [{
							name : "mongoose",
							value : null,
							type : TPath({
								sub : null,
								pack : ["js","npm","mongoose"],
								name : "Mongoose",
								params : []
							}),
							opt : null
						},{
							name : "name",
							value : null,
							type : TPath({
								sub : null,
								pack : [],
								name : "String",
								params : []
							}),
							opt : null
						},{
							name : "collectionName",
							value : null,
							type : TPath({
								sub : null,
								pack : [],
								name : "String",
								params : []
							}),
							opt : true
						},{
							name : "skipInit",
							value : null,
							type : TPath({
								sub : null,
								pack : [],
								name : "Bool",
								params : []
							}),
							opt : true
						}]
					}),
					access : [AStatic,APublic,AInline]
				});
			default :
				throw "not supported";
		}
		return fields;
	}

	static function anonTypeToSchemaDef( a : AnonType ) : ExprDef {
		var fields : Array<{ field : String, expr : haxe.macro.Expr }> = [];
		
		for( f in a.fields ){
			fields.push( classFieldToSchemaField(f) );
		}

		var objDecl = EObjectDecl( fields );

		return objDecl;
	}

	static function classFieldToSchemaField( f : ClassField ){
		var type = {
			pos : f.pos,
			expr : typeToSchemaType(f.type)
		};
		
		var expr = macro { type : $type };
		
		var fields = switch(expr.expr){
			case EObjectDecl( fields ) : fields;
			default : throw "assert";
		}

		for(m in f.meta.get()){
			var mname = m.name.substring(1);
			switch( mname ){
				case "required","select","sparse","unique" :
					// TODO : remove :optional when required ? throw error ?
					fields.push( { field : mname , expr : m.params.length == 0 ? macro true : m.params[0] } );
				case "default","index", "validate" :
					// TODO : add :optional when default ?
					if( m.params.length != 1 )
						Context.error( "Expected 1 value" , m.pos );
					fields.push( { field : mname , expr : m.params[0] } );
				case "get","set" :
					if( m.params.length != 1 )
							Context.error( "Getter expected" , m.pos );
						fields.push( { field : mname , expr : m.params[0] });
			}
						
		}
		//trace(type.expr);
		switch( type.expr ){
			case EConst( CIdent( "String" ) ) :
				for(m in f.meta.get()){
					//trace(m);
					var mname = m.name.substring(1);
					switch( mname ){
						case "trim","uppercase","lowercase" :
							fields.push( { field : mname , expr : m.params.length == 0 ? macro true : m.params[0] } );
						case "match":
							if( m.params.length != 1 ) 
								Context.error( "EReg expected" , m.pos );
							var regexp = m.params[0];
							
							fields.push( { field : mname , expr : macro js.support.RegExp.fromEReg( $regexp ) } );
						case "enum" :
							if( m.params.length != 1 )
								Context.error( "String values expected" , m.pos );
							var vals = m.params[0];
							
							fields.push( { field : mname , expr : macro ($vals : Array<String>) } );
						default:
					}
				}
			case EConst( CIdent( "Number" ) ) :
				for(m in f.meta.get()){
					//trace(m);
					var mname = m.name.substring(1);
					switch( mname ){
						case "min","max":
							if( m.params.length != 1 ) 
								Context.error( "Float expected" , m.pos );
							var val = m.params[0];
							
							fields.push( { field : mname , expr : macro ( $val : Float ) } );
					}
				}
			case EConst( CIdent( "Date" ) ) :
				for(m in f.meta.get()){
					//trace(m);
					var mname = m.name.substring(1);
					switch( mname ){
						case "expires":
							if( m.params.length != 1 ) 
								Context.error( "Date expected" , m.pos );
							var val = m.params[0];
							
							fields.push( { field : mname , expr : macro $val } );
					}
				}
			default:
		}

		return { field : f.name , expr : expr };
	}

	static function typeToSchemaType( type : Type ) : ExprDef {
		//trace(type);
		switch( type ){
			case TAnonymous( a ) :
				return anonTypeToSchemaDef( a.get() );

			case TInst( t , params ) :
				var i = t.get();
				var fullname = i.pack.join(".") + ( i.pack.length > 0 ? "." : "" ) + i.name;
				var expr = switch( fullname ){
					case "String" : 
						macro String;
					case "Array" :
						var t = { expr : typeToSchemaType(params[0]) , pos : Context.currentPos() };
						macro [$t];
					case "Date" :
						macro Date;
					case "js.node.Buffer" :
						macro js.node.Buffer;
					case "js.npm.mongoose.schema.types.ObjectId" :
						macro js.npm.mongoose.schema.types.ObjectId;
					default : 
						macro js.npm.mongoose.schema.types.Mixed;
				}
				return expr.expr;

			case TAbstract( t , params ) :
				var i = t.get();
				var fullname = i.pack.join(".") + ( i.pack.length > 0 ? "." : "" ) + i.name;
				var expr = switch( fullname ){
					case "Float","Int" :
						macro js.Number;
					case "Bool" :
						macro Bool;
					default : 
						macro js.npm.mongoose.schema.types.Mixed;
				}
				return expr.expr;

			default : 
				var expr = macro js.npm.mongoose.schema.types.Mixed;
				return expr.expr;
		}

	}
}