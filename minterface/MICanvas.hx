package minterface;

import minterface.MITypes;
import minterface.MIControl;

class MICanvas extends MIControl {

	public var focused : MIControl;
	public var dragged : MIControl;

	public function new( _options:Dynamic ) {

		if(_options == null) throw "No options given to canvas, at least a MIRenderer is required.";
		if(_options.renderer == null) throw "No renderer given to MICanvas, cannot create this way.";
		if(_options.name == null) _options.name = 'canvas';
		if(_options.bounds == null) _options.bounds = new MIRectangle(0, 0, 800, 600 );

		renderer = _options.renderer;

		super(_options);
		if(_options.parent == null) {
			canvas = this;
		} else {
			canvas = _options.parent;
		} //parent null

		mouse_enabled = true;
		focused = null;
		depth = _options.depth;

		renderer.canvas.init( this, _options );

		_mouse_last = new MIPoint();

	} //new

	public override function set_visible( ?_visible:Bool = true ) {
		super.set_visible(_visible);
		renderer.canvas.set_visible(this, _visible);
	} //set_visible


	private override function set_depth( _d:Float ) : Float {

		renderer.canvas.set_depth(this, _d);

		return depth = _d;

	} //set_depth

	public function topmost_control_under_point( _p:MIPoint ) {
		var _control = topmost_child_under_point(_p);
		if(_control != this) return _control;
		return null;
	}

	var _mouse_last:MIPoint;

	private function set_control_unfocused(_control:MIControl, e:MIMouseEvent, ?do_mouseleave:Bool = true) {
		if(_control != null) {

			_control.ishovered = false;
			_control.isfocused = false;

			if(_control.mouse_enabled && do_mouseleave) {
				_control.onmouseleave(e);
			} //mouse enabled and we want handlers

		} //_control != null
	} //set_unfocused

	private function set_control_focused(_control:MIControl, e:MIMouseEvent, ?do_mouseenter:Bool = true) {
		if(_control != null) {
			_control.ishovered = true;
			_control.isfocused = true;

			if(_control.mouse_enabled && do_mouseenter) {
				_control.onmouseenter(e);
			} //mouse enabled and we want handlers
		}
	} //set_focused

	public override function onmousemove( e:MIMouseEvent ) {
		
		_mouse_last.set(e.x,e.y);

			//first we check if the mouse is still inside the focused element
		if(focused != null) {

			if(focused.real_bounds.point_inside(_mouse_last)) {

					//now check if we haven't gone into any of it's children
				var _child_over = focused.topmost_child_under_point(_mouse_last);
				if(_child_over != null && _child_over != focused) {
							
						//if we don't want mouseleave when the child takes focus, set to false
					var _mouseleave_parent = true;
						//unfocus the parent
					set_control_unfocused(focused, e, _mouseleave_parent);
						//focus the child now
					set_control_focused(_child_over, e);
						//change the focused item
					focused = _child_over;

				} //child_over != null

			} else { //focused.real_bounds point_inside( mouse )

					//unfocus the existing one
				set_control_unfocused(focused, e);

					//find a new one, if any
				focused = topmost_control_under_point( _mouse_last );

					if(focused != null) {
						set_control_focused( focused, e );
					} //focused != null
			
			} //focused inside

		} else { //focused != null

				//nothing focused at the moment, check that the mouse is inside our canvas first
			if( real_bounds.point_inside(_mouse_last) ) {

				focused = topmost_control_under_point( _mouse_last );

					if(focused != null) {
						set_control_focused( focused, e );
					}

			} else { //mouse is inside canvas at all?

				focused = null;

			} //inside canvas

		} //focused == null

		if(focused != null && focused != this) {
			focused.onmousemove(e);
		} //focused != null
		
		if(dragged != null && dragged != focused && dragged != this) {
			dragged.onmousemove(e);
		} //dragged ! null and ! focused

	} //onmousemove
	
	public override function onmouseup( e:MIMouseEvent ) {

		_mouse_last.set(e.x,e.y);
		
		if(focused != null && focused.mouse_enabled) {
			focused.onmouseup(e);
		} //focused

	} //onmouseup

	public override function onmousedown( e:MIMouseEvent ) {
		
		_mouse_last.set(e.x,e.y);
		
		if(focused != null && focused.mouse_enabled) {
			focused.onmousedown(e);
		} //focused

	} //onmousedown

	public function next_depth() {
		depth++;
		return depth;
	} //next_depth

	public override function add( child:MIControl ) {
		super.add(child);		
	} //add

	public function update(dt:Float) {
	} //update

	public function destroy(){

	} //destroy

} //MICanvas