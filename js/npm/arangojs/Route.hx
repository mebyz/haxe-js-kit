package js.npm.arangojs;

import js.support.Either;

typedef RouteRequestOptions = {
	?path : String,
	?absolutePath : Bool,
	?body : Either<String, {}>,
	?qs : Either<String, {}>,
	?headers : {},
	?method : String
}

extern class Route {
	@:overload(function() : Route {})
	@:overload(function(headers : {}) : Route {})	
	@:overload(function(path : String) : Route {})
	public function route(path : String, headers : {}) : Route;
	
	@:overload(function<T>(cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(qs : {}, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(path : String, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	public function get<T>(path : String, qs : Either<String, {}>, cb : ArangoCallback<RouteResponse<T>>) : Void;
	
	@:overload(function<T>(cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(path : String, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(path : String, body : Either<String, {}>, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	public function post<T>(path : String, body : Either<String, {}>, qs : Either<String, {}>, cb : ArangoCallback<RouteResponse<T>>) : Void;

	@:overload(function<T>(cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(path : String, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(path : String, body : Either<String, {}>, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	public function put<T>(path : String, body : Either<String, {}>, qs : Either<String, {}>, cb : ArangoCallback<RouteResponse<T>>) : Void;	
	
	@:overload(function<T>(cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(path : String, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(path : String, body : Either<String, {}>, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	public function patch<T>(path : String, body : Either<String, {}>, qs : Either<String, {}>, cb : ArangoCallback<RouteResponse<T>>) : Void;	

	@:overload(function<T>(cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(qs : {}, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(path : String, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	public function delete<T>(path : String, qs : Either<String, {}>, cb : ArangoCallback<RouteResponse<T>>) : Void;

	@:overload(function<T>(cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(qs : {}, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	@:overload(function<T>(path : String, cb : ArangoCallback<RouteResponse<T>>) : Void {})
	public function head<T>(path : String, qs : Either<String, {}>, cb : ArangoCallback<RouteResponse<T>>) : Void;
	
	@:overload(function<T>(cb : ArangoCallback<RouteResponse<T>>) : Void {})
	public function request<T>(opts : RouteRequestOptions, cb : ArangoCallback<RouteResponse<T>>) : Void;
}
