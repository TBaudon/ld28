package com.pixodrome.ld28;
import flash.display.BitmapData;
import flash.utils.ByteArray;
import lime.gl.GLTexture;
import openfl.gl.GL;

/**
 * ...
 * @author Thomas BAUDON
 */
class Texture
{
	public var texture : GLTexture;
	
	public function new(_path : String) 
	{
		var bitmapData = Assets.getBitmapData(_path);
		
		texture = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, texture);
		
		var pixels : ByteArray = bitmapData.getPixels(bitmapData.rect);
		
		#if html5
		var array = new Array<Int>();

		pixels.position = 0;
		for (i in 0 ... pixels.length)
			array.push(pixels.readUnsignedByte());
		GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 1);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, bitmapData.width, bitmapData.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, new UInt8Array(array));
		#else
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, bitmapData.width, bitmapData.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, new UInt8Array(pixels));
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		GL.generateMipmap(GL.TEXTURE_2D);
        GL.bindTexture(GL.TEXTURE_2D, null);
	}
}