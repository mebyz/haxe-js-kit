package js.npm.arangojs;

import js.node.http.IncomingMessage;

extern class RouteResponse<T> extends IncomingMessage {
	public var body : T;
	public var rawBody : String;
}
