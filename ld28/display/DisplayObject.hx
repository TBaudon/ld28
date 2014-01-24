package ld28.display;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import ld28.Color;
import ld28.core.IDrawable;
import ld28.core.Texture;
import ld28.Scene;
import ld28.shaders.Basic2DShader;
import ld28.core.Program;
import ld28.shaders.SpriteBatch2DShader;
import openfl.gl.GL;
import openfl.gl.GLUniformLocation;
import openfl.utils.Float32Array;

/**
 * ...
 * @author Thomas BAUDON
 */
class DisplayObject implements IDrawable
{
	public var x : Float;
	public var y : Float;
	
	public var rotation : Float;
	
	public var scaleX : Float;
	public var scaleY : Float;
	
	public var pivotX : Float;
	public var pivotY : Float;
	
	public var width : Int;
	public var height : Int;
	
	public var color : Color;
	
	public var alpha : Float;
	
	public var parent : DisplayObjectContainer;
	
	var mesh : Mesh;
	var program : Program;
	
	var transform : Matrix;
	var matrixArray : Float32Array;
	
	var vtxPosAttr : Int;
	
	var projectionMatrixUniform : GLUniformLocation;
	var modelViewMatrixUniform : GLUniformLocation;
	var colorUniform : GLUniformLocation;

	public function new(_mesh : Mesh, _program : Program = null) 
	{
		mesh = _mesh;
		
		x = 0;
		y = 0;
		
		rotation = 0;
		
		scaleX = 1;
		scaleY = 1;
		
		pivotX = 0;
		pivotY = 0;
		
		alpha = 1;
		
		color = new Color(0xffffff);
		transform = new Matrix();
		matrixArray = new Float32Array([transform.a, transform.b, transform.tx, transform.c, transform.d, transform.ty,0,0,1]);
		
		if (_program == null)
			_program = ShaderManager.get().program(Basic2DShader);
		program = _program;
		
		GL.useProgram(program.program);
		initAttributes();
		initUniforms();
	}
	
	function initAttributes() 
	{
		vtxPosAttr = GL.getAttribLocation(program.program, "vertexPosition");
	}
	
	function initUniforms() 
	{
		projectionMatrixUniform = GL.getUniformLocation(program.program, "projectionMatrix");
		modelViewMatrixUniform = GL.getUniformLocation(program.program, "modelViewMatrix");
		colorUniform = GL.getUniformLocation(program.program, "vertexColor");
	}
	
	public function getTransform() : Matrix
	{
		return transform;
	}
	
	public function getMesh() : Mesh
	{
		return mesh;
	}
	
	public function draw(scene : Scene)
	{
		initRender(scene);
		
		GL.bindBuffer (GL.ARRAY_BUFFER, mesh.getBuffer());
		GL.vertexAttribPointer (vtxPosAttr, 2, GL.FLOAT, false, 0, 0);
			
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, mesh.getIndexBuffer());
		
		GL.drawElements(GL.TRIANGLES, mesh.indexes.length, GL.UNSIGNED_SHORT, 0);
		
		GL.disable(GL.BLEND);
	}
	
	private function updateMatrix() 
	{
		transform.identity();
		
		transform.translate( -pivotX, -pivotY);
		transform.rotate(rotation);
		transform.scale(scaleX, scaleY);
		transform.translate(x + pivotX, y + pivotY);
		
		if (parent != null)
			transform.concat(parent.getTransform());
		
		matrixArray[0] = transform.a;
		matrixArray[1] = transform.b;
		matrixArray[2] = transform.tx;
		matrixArray[3] = transform.c;
		matrixArray[4] = transform.d;
		matrixArray[5] = transform.ty;
	}
	
	private function initRender(scene : Scene)
	{
		updateMatrix();
		
		program.use();
		
		GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
		GL.enable(GL.BLEND);
		GL.disable(GL.DEPTH_TEST);
		
		GL.enableVertexAttribArray(vtxPosAttr);
		
		GL.uniformMatrix3D(projectionMatrixUniform, false, scene.projectionMatrix);
		GL.uniformMatrix3fv(modelViewMatrixUniform, false, matrixArray);
		GL.uniform4f(colorUniform, color.r, color.g, color.b, color.a);
	}
	
}