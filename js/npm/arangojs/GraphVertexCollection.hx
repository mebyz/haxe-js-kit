package js.npm.arangojs;
import js.support.Either;

extern class GraphVertexCollection extends Collection
//implements npm.Package.Require<"arangodb", "^4.3.0">
{
	public function vertex<T>(documentHandle : Either<String, {}>, cb : ArangoCallback<T>) : Void;
	public function save(data : {}, cb : ArangoCallback<{}>) : Void;
}
