package ld28;

import ld28.Renderer;
import flash.geom.Rectangle;
import motion.Actuate;
import motion.easing.Bounce;

/**
 * ...
 * @author Thomas BAUDON
 */
class App
{
	var renderer : Renderer;
	
	var pawns : Array<Array<Pawn>>;
	
	var nbColumns : Int = 10;
	var nbLine : Int = 16;
	var movingPawn : Int = 0;
	
	var fullScreenBtn : Model;

	public function new() 
	{
		initRenderer();
		
		pawns = new Array<Array<Pawn>>();
		
		for (i in 0 ... nbLine)
		{
			var line = new Array<Pawn>();
			for (j in 0 ... nbColumns)
			{
				var pawn = new Pawn(Std.int (Math.random() * 4 + 1));
				pawn.position.x = j * pawn.getBoundingBox().width;
				pawn.position.y = i * pawn.getBoundingBox().height;
				
				line.push(pawn);
				renderer.add(pawn);
			}
			pawns.push(line);
		}
	}
	
	function initRenderer():Void 
	{
		renderer = new Renderer();
	}
			
	public function update() 
	{
	}
	
	public function render(viewport : Rectangle) 
	{
		this.renderer.render(viewport);
	}
	
	public function onTouchDown(x : Int, y : Int) : Void
	{
		x = cast (x * (480 / Main.screenWidth));
		y = cast (y * (768 / Main.screenHeigth));
		
		destroyGroup(x,y);
	}
	
	function makeFall() 
	{
		for (i in 0 ... nbColumns)
		{
			var j = nbLine - 1;
			while ( j > 0)
			{
				var pawn = pawns[j][i];
				
				if (pawn == null)
				{
					var v = 1;
					var stop = false;
					while (j - v >= 0 && pawns[j - v][i] == null)
					{
						v++;
						if (j - v < 0)
							stop = true;
					}
					if (stop) break;
					pawns[j][i] = pawns[j - v][i];
					pawns[j - v][i] = null;
					
					Actuate.tween(pawns[j][i].position, 0.5, { y:j * 48 } ).ease(Bounce.easeOut).onComplete(moveEnd);
					movingPawn++;
				}
				j--;
			}
		}
	}
	
	public function moveEnd()
	{
		movingPawn--;
		
		if (movingPawn == 0)
		{
			var i = 0;
			var a : Int = nbLine -1;
			while (i < nbColumns)
			{
				var pawn = pawns[a][i];
				
				if (pawn == null)
				{
					var v = 1;
					var stop = false;
					while (i + v <= nbColumns && pawns[a][i + v] == null)
					{
						v++;
						if (i + v < 0)
							stop = true;
					}
					if (stop) break;
					for (j in 0 ... nbLine)
					{
						pawns[j][i] = pawns[j][i + v];
						pawns[j][i + v] = null;
						
						if (pawns[j][i] != null)
						{
							Actuate.tween(pawns[j][i].position, 0.5, { x:i * 48 } ).ease(Bounce.easeOut).onComplete(moveEnd);
							movingPawn++;
						}
					}
				}
				i++;
			}
		}
	}
	
	public function onTouchUp(x : Int, y : Int) : Void
	{
	}
	
	public function onTouchMove(x : Int, y : Int) : Void
	{
	}
	
	private function checkPawns(x : Int, y : Int, color : Int) : Void
	{
		var pawn : Pawn = pawns[y][x]; 
		
		if (pawn == null)
			return;
		pawn.checked = true;
		
		if (x + 1 < nbColumns)
		{
			pawn = pawns[y][x + 1];
			if (pawn!= null && pawn.color == color && pawn.checked == false)
				checkPawns(x + 1, y, color);
		}
		
		if (x - 1 >= 0)
		{
			pawn = pawns[y][x - 1];
			if (pawn!= null && pawn.color == color && pawn.checked == false)
				checkPawns(x - 1, y, color);
		}
		
		if (y + 1 < nbLine)
		{
			pawn = pawns[y + 1][x];
			if (pawn!= null && pawn.color == color && pawn.checked == false)
				checkPawns(x, y + 1, color);
		}
		
		if (y - 1 >= 0)
		{
			pawn = pawns[y - 1][x];
			if (pawn!= null && pawn.color == color && pawn.checked == false)
				checkPawns(x, y - 1, color);
		}
	}
	
	function destroyGroup(x : Int, y: Int):Void 
	{
		if (movingPawn > 0)
			return;
		
		var clickX = Std.int(x / 48);
		var clickY = Std.int(y / 48);
		
		if (clickY > nbLine -1 || clickX > nbColumns -1)
			return;
		
		var clickedPawn : Pawn = pawns[clickY][clickX];
		if (clickedPawn == null)
			return;
		
		checkPawns(clickX, clickY, clickedPawn.color);
		
		var hasToMakeFall = false;
		
		for (i in 0 ... nbLine)
		{
			for (j in 0 ... nbColumns)
			{
				var pawn = pawns[i][j];
				if (pawn != null && pawn.checked)
				{
					pawn.rotation.z = 1;
					Actuate.tween(pawn.scale, 0.5, { x:0, y:0 } ).onComplete(renderer.remove, [pawn]);
					Actuate.tween(pawn.rotation, 0.5, { w:360 } );
					hasToMakeFall = true;
					var x = Std.int(pawn.position.x / 48);
					var y = Std.int(pawn.position.y / 48);
					pawns[y][x] = null;
				}
			}
		}
		
		if(hasToMakeFall)
			makeFall();
	}
}
