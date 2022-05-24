package{
		import flash.display.MovieClip;
		import flash.display.Stage;
		import flash.display.Loader;
		import flash.display.DisplayObject;
		import flash.display.Graphics;
		import flash.display.Shape;
		import flash.geom.Point;
		import flash.text.TextField;
		import flash.events.MouseEvent;
		import flash.events.Event;
	  	import flash.net.URLLoader;
	  	import flash.net.URLRequest;

		import com.dncompute.graphics.GraphicsUtil;

		public class diagramClass_v2 extends MovieClip{
			//class vars
			private var lastStep:String;
			private var lastStepNum:int;
			private var settings:XML;
			private var posGrid:XML;
			private var diagram:XML;
			private var desc:comment_mc = new comment_mc();
			private var commentName:String;
			private var newBtn=new new_btn();
			private var newDesc=new newComment();
			private var newDescOn:Boolean=false;
			private var news:String;
			
			public function diagramClass_v2(){
				
				//load position grid
				var gridLoader:URLLoader = new URLLoader();
				gridLoader.addEventListener(Event.COMPLETE, gridLoaded);
				gridLoader.load(new URLRequest("grid.xml"));
				
				//load diagram
				var diagramLoader:URLLoader = new URLLoader();
				diagramLoader.addEventListener(Event.COMPLETE, diagramLoaded);
				diagramLoader.load(new URLRequest("components.xml"));
				
				
				//load settings
				var settingsLoader:URLLoader = new URLLoader();
				settingsLoader.addEventListener(Event.COMPLETE, settingsLoaded);
				settingsLoader.load(new URLRequest("arrows.xml"));
			}//end constructor
			
			private function gridLoaded(e:Event):void
			{
				posGrid=XML(e.target.data);
			}
			
			
			private function diagramLoaded(evt:Event):void
			{
				diagram=XML(evt.target.data);
				diagram.ignoreWhitespace = true;
				for ( var i=0; i < diagram.comp.length(); i++)
				{
					if(diagram.comp[i].@active=="1")
					{
						var theComp=new server();
						theComp.title.text=diagram.comp[i];

						for(var j=0; j<posGrid.pos.length(); j++)
						{
							if(diagram.comp[i].@pos == posGrid.pos[j])
							{
								theComp.x= posGrid.pos[j].@xpos;
								theComp.y= posGrid.pos[j].@ypos;
							}
						}

						addChild(theComp);
					}
				}
			}
			
			
			
			private function settingsLoaded(e:Event):void
			{
				//trace(e.target.data);
				settings=XML(e.target.data);
				settings.ignoreWhitespace = true;
				
				title.text=settings.@title;
				lastStep=settings.@steps;
				lastStepNum=int(lastStep);
				var len=settings.step.length(); //    () required for xml
				for (var i=0; i<len; i++)
				{
					//draw arrow
					var beginX:int=int(settings.step[i].begin.@xpos);
					var beginY:int=int(settings.step[i].begin.@ypos);
					var endX:int=int(settings.step[i].end.@xpos);
					var endY:int=int(settings.step[i].end.@ypos);
					var midX:int=(beginX + endX)/2;
					var midY:int=(beginY + endY)/2;
					var stepNum:String=settings.step[i].@num;
					
					//draw arrow
					if(settings.step[i].@arrow=="1")
					{
						drawArrows(beginX, beginY, endX, endY);
					}//end if
					
					//create step button if needed, btn = "1"
					if(settings.step[i].@btn=="1")
					{
						var buttonPos:String = settings.step[i].@btnpos
						switch(buttonPos)
						{
							case "start":
								showSteps(stepNum, beginX, beginY);
								break;
							case "end":
								showSteps(stepNum, endX, endY);
								break;
							default:	
								showSteps(stepNum, midX, midY);
								break;
						}//end switch
					}//end if
				}//end for
				news=settings.news;
				addWhatsNew();
				
			}//end function settingsLoaded
			
			private function addWhatsNew()
			{
				newBtn.x=864;
				newBtn.y=565;
				newBtn.addEventListener(MouseEvent.CLICK, loadWhatsNew);
				addChild(newBtn);
			}
			
			private function loadWhatsNew(e:MouseEvent)
			{
				newDesc.x=stage.stageWidth/2 - newDesc.width/2;
				newDesc.y=stage.stageHeight/2 - newDesc.height/2;
				newDesc.visible=true;
				newDesc.commentText.text=news;
				addChild(newDesc);
				newDescOn=true;
				newDesc.visible=true;
			}
			
			private function removeWhatsNew()
			{
				if(newDescOn==true)
				{
					//removeChild(newDesc);
					newDesc.visible=false;
				}
			}
			
			
			private function drawArrows(sX:int, sY:int, eX:int, eY:int){
				var bX=sX;
				var bY=sY;
				var fX=eX;
				var fY=eY;
				
				var shape:Shape = new Shape();
				shape.graphics.lineStyle(1,0x000000);
				shape.graphics.beginFill(0x999999);
				GraphicsUtil.drawArrow(shape.graphics,new Point(bX,bY),new Point(fX,fY));
				addChild(shape);

			}//end drawArrows
			
			private function showSteps(sNum:String, sX:int, sY:int){
				var step:Step = new Step();
				var sbstepX=int(sNum);
				step.x=sX;
				step.y=sY;
				step.stepNum.text=sNum;
				step.buttonMode=true;
				step.mouseChildren = false;
				//to show description
				step.addEventListener(MouseEvent.MOUSE_OVER, showDesc(sNum,sX,sY));
				step.addEventListener(MouseEvent.MOUSE_OUT, hideDesc);
				step.name="step"+sNum;
				addChild(step);
				showstepByStep(sNum,sbstepX);
				
			}
			
			private function showDesc(stepNum:String,btX:int,btY:int):Function
			{
				
				return function(evt:MouseEvent)
				{
					var theComment:comment_mc = new comment_mc();
					commentName=stepNum;
					//theComment.commentText.width=216.1;
					//theComment.commentText.height=485.1;
					//theComment.slider.height=170;
					theComment.commentText.wordWrap = true;
					theComment.name=commentName;
					theComment.title.text="Step "+stepNum;
					for (var i=0; i<settings.step.length(); i++)
					{
						if(settings.step[i].@num==stepNum  && settings.step[i].@btn=="1")
						{
							theComment.commentText.text = settings.step[i].desc;
						}
					}
					
					theComment.x=749.2;
					theComment.y=39;
					instruct.visible=false;
					addChild(theComment);
					removeWhatsNew();
				}
			}
			
			private function hideDesc(evt:MouseEvent)
			{
				removeChild(getChildByName(commentName));
			}
			
			
			private function showstepByStep(thisStepNum:String, thisX:int)
			{
				var myStep:String=thisStepNum;
				var thisStep=new stepByStep();
				
				var showX= this.getChildByName("step"+myStep).x;
				var showY= this.getChildByName("step"+myStep).y;
				var startX= (980-lastStepNum * 25)/2
				thisStep.y=575;
				thisStep.x=startX + thisX * 25;
				
				thisStep.stepNum.text=myStep;
				thisStep.addEventListener(MouseEvent.MOUSE_OVER, hideOtherSteps);
				thisStep.addEventListener(MouseEvent.MOUSE_OVER, showThisStep(myStep));
				thisStep.addEventListener(MouseEvent.MOUSE_OVER, showDesc(myStep,showX,showY))
				thisStep.addEventListener(MouseEvent.MOUSE_OUT, hideThisStep(myStep));
				thisStep.addEventListener(MouseEvent.MOUSE_OUT, showOtherSteps);
				thisStep.addEventListener(MouseEvent.MOUSE_OUT, hideDesc);
				addChild(thisStep);
			}
			
			private function hideOtherSteps(evt:MouseEvent)
			{
				
				//trace(lastStep);
				for (var i=1; i<=int(lastStep); i++)
				{
					var hideThis:String="step"+String(i);
					this.getChildByName(hideThis).alpha=0;
				}
			}
			
			private function showOtherSteps(evt:MouseEvent)
			{
				//trace(lastStep);
				for (var i=1; i<=int(lastStep); i++)
				{
					var hideThis:String="step"+String(i);
					this.getChildByName(hideThis).alpha=1;
				}
			}
			
			private function showThisStep(theStep:String):Function
			{
				//
				var childName="step"+theStep;
				var mc=this.getChildByName(childName);
				return function(evt:MouseEvent)
				{
					mc.alpha=1;
					mc.gotoAndStop(2);
					instruct.visible=false;
				}
			}
			
			private function hideThisStep(theStep:String):Function
			{
				var childName="step"+theStep;
				var mc=this.getChildByName(childName);
				return function(evt:MouseEvent)
				{
					mc.gotoAndStop(1);
				}
			}
				
		}//end class
}//end package