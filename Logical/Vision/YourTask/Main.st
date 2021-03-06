// -----------------------------------------------------------------------------------------------------------
// Use this task to add your own code
// -----------------------------------------------------------------------------------------------------------	

// -----------------------------------------------------------------------------------------------------------
// Initialization
// -----------------------------------------------------------------------------------------------------------	
PROGRAM _INIT
	// -----------------------------------------------------------------------------------------------------------
	// Vision sensor configuration
	// -----------------------------------------------------------------------------------------------------------	
	// Configuration for blob
	gVisionSensor[1].CFG.VisionFunction	:= enumBlob;		// Used to run specific code for this vision function
	gVisionSensor[1].CFG.PowerlinkNode	:= 1;				// Powerlink node number
	gVisionSensor[1].CFG.DataStructure	:= ADR(gBlob);		// Global structures that holds all data related to this function
	gVisionSensor[1].CFG.ComponentLink	:= gCameraBlob;		// Vision component name defined under mappVision in the configuration view
	// Configuration for code reader
	gVisionSensor[2].CFG.VisionFunction	:= enumCoderReader;
	gVisionSensor[2].CFG.PowerlinkNode	:= 2;
	gVisionSensor[2].CFG.DataStructure	:= ADR(gCodeReader);
	gVisionSensor[2].CFG.ComponentLink	:= gCameraCodeReading;
	// Configuration for match
	gVisionSensor[3].CFG.VisionFunction	:= enumMatch;
	gVisionSensor[3].CFG.PowerlinkNode	:= 3;
	gVisionSensor[3].CFG.DataStructure	:= ADR(gMatch);
	gVisionSensor[3].CFG.ComponentLink	:= gCameraMatch;
	// Configuration for meaurement
	gVisionSensor[4].CFG.VisionFunction	:= enumMeasurement;
	gVisionSensor[4].CFG.PowerlinkNode	:= 4;
	gVisionSensor[4].CFG.DataStructure	:= ADR(gMT);
	gVisionSensor[4].CFG.ComponentLink	:= gCameraMeasurement;
	// Configuration for OCR
	gVisionSensor[5].CFG.VisionFunction	:= enumOCR;
	gVisionSensor[5].CFG.PowerlinkNode	:= 5;
	gVisionSensor[5].CFG.DataStructure	:= ADR(gOCR);
	gVisionSensor[5].CFG.ComponentLink	:= gCameraOCR;

	// -----------------------------------------------------------------------------------------------------------
	// Lights configuration
	// -----------------------------------------------------------------------------------------------------------	
	// Configuration for backlights
	gVisionLight[1].CFG.LightType		:= enumBacklight;
	gVisionLight[1].CFG.PowerlinkNode	:= 10;
	gVisionLight[1].DAT.FlashColor		:= 1;
	gVisionLight[2].CFG.LightType		:= enumBacklight;
	gVisionLight[2].CFG.PowerlinkNode	:= 11;
	gVisionLight[2].DAT.FlashColor		:= 1;
	// Configuration for lightbars
	gVisionLight[3].CFG.LightType		:= enumLightbar;
	gVisionLight[3].CFG.PowerlinkNode	:= 20;
	gVisionLight[3].DAT.FlashColor		:= 1;
	
	cmdLoadRecipeAfterBoot	:= TRUE;
END_PROGRAM

// -----------------------------------------------------------------------------------------------------------
// Cyclic part
// -----------------------------------------------------------------------------------------------------------	
PROGRAM _CYCLIC
	// -----------------------------------------------------------------------------------------------------------	
	// Trigger selected backlight when selected sensor is triggered
	IF(EDGEPOS(gVisionSensor[visSelectedSensor].CMD.ImageTrigger)) THEN
		gVisionLight[visSelectedLight].DAT.Exposure		:= gVisionSensor[visSelectedSensor].DAT.Exposure;
		gVisionLight[visSelectedLight].DAT.NettimeDelay	:= gVisionSensor[visSelectedSensor].DAT.NettimeDelay;
		gVisionLight[visSelectedLight].CMD.FlashTrigger	:= TRUE;
	END_IF
	
	// -----------------------------------------------------------------------------------------------------------	
	// Transfer data when loading a recipe
	IF EDGENEG(Recipe_01.CMD.Load) OR cmdLoadRecipeAfterBoot THEN
		cmdLoadRecipeAfterBoot := FALSE;
		FOR i := 1 TO MAX_NUM_CAMS DO
			gVisionSensor[i].FCT.ApplicationName	:= RecipeData.Cam[i].ApplicationName;
			gVisionSensor[i].DAT.Exposure			:= RecipeData.Cam[i].Exposure;
			gVisionSensor[i].DAT.FlashColor			:= RecipeData.Cam[i].FlashColor;
			gVisionSensor[i].DAT.FlashSegment		:= RecipeData.Cam[i].FlashSegment;
			gVisionSensor[i].DAT.Focus				:= RecipeData.Cam[i].Focus;
			gVisionSensor[i].DAT.Gain				:= RecipeData.Cam[i].Gain;
			gVisionSensor[i].DAT.MaxItemCnt			:= RecipeData.Cam[i].MaxItemCnt;
			gVisionSensor[i].DAT.Timeout			:= RecipeData.Cam[i].Timeout;
		END_FOR
		FOR i := 1 TO MAX_NUM_LIGHTS DO
			gVisionLight[i].DAT.Exposure			:= RecipeData.Light[i].Exposure;
			gVisionLight[i].DAT.FlashColor			:= RecipeData.Light[i].FlashColor;
			gVisionLight[i].DAT.FlashSegment		:= RecipeData.Light[i].FlashSegment;
			gVisionLight[i].DAT.SetAngle			:= RecipeData.Light[i].SetAngle;
			gVisionLight[i].DAT.Timeout				:= RecipeData.Light[i].Timeout;
		END_FOR
		// Switch vision application when recipe for blob was loaded
		gVisionSensor[1].CMD.VaSwitchApplication := TRUE;
	END_IF
	
	// -----------------------------------------------------------------------------------------------------------	
	// Transfer data cyclic to the remanent variable
	IF NOT Recipe_01.CMD.Load THEN
		FOR i := 1 TO MAX_NUM_CAMS DO
			RecipeData.Cam[i].ApplicationName	:= gVisionSensor[i].FCT.ApplicationName;
			RecipeData.Cam[i].Exposure			:= gVisionSensor[i].DAT.Exposure;
			RecipeData.Cam[i].FlashColor		:= gVisionSensor[i].DAT.FlashColor;
			RecipeData.Cam[i].FlashSegment		:= gVisionSensor[i].DAT.FlashSegment;
			RecipeData.Cam[i].Focus				:= gVisionSensor[i].DAT.Focus;
			RecipeData.Cam[i].Gain				:= gVisionSensor[i].DAT.Gain;
			RecipeData.Cam[i].MaxItemCnt		:= gVisionSensor[i].DAT.MaxItemCnt;
			RecipeData.Cam[i].Timeout			:= gVisionSensor[i].DAT.Timeout;
		END_FOR
		FOR i := 1 TO MAX_NUM_LIGHTS DO
			RecipeData.Light[i].Exposure		:= gVisionLight[i].DAT.Exposure;
			RecipeData.Light[i].FlashColor		:= gVisionLight[i].DAT.FlashColor;
			RecipeData.Light[i].FlashSegment	:= gVisionLight[i].DAT.FlashSegment;
			RecipeData.Light[i].SetAngle		:= gVisionLight[i].DAT.SetAngle;
			RecipeData.Light[i].Timeout			:= gVisionLight[i].DAT.Timeout;
		END_FOR
	END_IF
	IF visSaveRecipe OR visNewRecipe THEN
		IF(visNewRecipe) THEN
			Recipe_01.CMD.New := TRUE;
		ELSE
			Recipe_01.CMD.Save := TRUE;
		END_IF
		visNewRecipe := FALSE;
		visSaveRecipe := FALSE;
	END_IF
END_PROGRAM