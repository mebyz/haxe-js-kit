package js.npm.arangojs;
import js.support.Either;

typedef GraphEdgeCollection = Collection;

typedef EdgeDefinition = {
	collection : String,
	from: Array<String>,
	to: Array<String>
}

extern class Graph 
{
	public function get(cb : ArangoCallback<Dynamic>) : Void;
	public function create(properties : {}, cb : ArangoCallback<Dynamic>) : Void;
	@:overload(function(cb : ArangoCallback<Dynamic>) : Void {})
	public function drop(dropCollections : Bool, cb : ArangoCallback<Dynamic>) : Void;

	public function vertexCollection(collectionName : String) : GraphVertexCollection;
	public function addVertexCollection(collectionName : String, cb : ArangoCallback<Dynamic>) : Void;
	@:overload(function(collectionName : String, cb : ArangoCallback<Dynamic>) : Void {})
	public function removeVertexCollection(collectionName : String, dropCollection : Bool, cb : ArangoCallback<Dynamic>) : Void;

	public function edgeCollection(collectionName : String) : GraphEdgeCollection;
	public function addEdgeDefinition(definition : EdgeDefinition, cb : ArangoCallback<Dynamic>) : Void;
	public function replaceEdgeDefinition(collectionName : String, definition : EdgeDefinition, cb : ArangoCallback<Dynamic>) : Void;
	@:overload(function(definitionName : String, cb : ArangoCallback<Dynamic>) : Void {})
	public function removeEdgeDefinition(definitionName : String, dropCollection : Bool, cb : ArangoCallback<Dynamic>) : Void;	
	
	public function traversal<T>(startVertex : String, opts : {}, cb : ArangoCallback<T>) : Void;
}
