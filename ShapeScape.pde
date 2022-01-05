//IMPORT
import processing.pdf.*;

import controlP5.*;

import java.awt.Toolkit;
import java.awt.datatransfer.*;

import org.apache.pdfbox.pdmodel.*;
import org.apache.pdfbox.pdmodel.graphics.*;
import org.apache.pdfbox.cos.*;

//DECLARE
float opacity,
maxSizeMultiplier, minSizeMultiplier,
strokeOpacity, strokeWidth,
rotateMax, rotateMin,
widthRatio, heightRatio,
startBackR, startBackG, startBackB,
startShapeR, startShapeG, startShapeB,
randomBackR, randomBackG, randomBackB,
randomShapeR, randomShapeG, randomShapeB,
natDev, natTight;
int lerpFrequency, currentShapeCount, maxShapeCount,
currentW, currentH,
placementX, placementY,
currentBlendMode, currentShape, lastShape,
borderSize, undoAmount,
currentBoxNum, preset, waves, natPoints;
String seed, docsPath;
boolean guiState, hsbMode, hsbLabeled, triUp, triDown, lastUp, lastDown, modPressed, cPressed, vPressed;
String[] prefs, defaultPrefs, imageSaveCount;
PImage raster;

ArrayList<String> prevSeeds = new ArrayList<String>();
ArrayList<Textfield> boxes = new ArrayList<Textfield>();
ArrayList<Textfield> boxesVis = new ArrayList<Textfield>();

ControlP5 cp5;
ControlFont f;
Slider maxShapeCountSlider, opacitySlider, lerpFrequencySlider,
maxSizeMultiplierSlider, minSizeMultiplierSlider,
startBackRSlider, startBackGSlider, startBackBSlider,
startShapeRSlider, startShapeGSlider, startShapeBSlider,
strokeOpacitySlider, strokeWidthSlider,
borderSizeSlider,
rotateMinSlider, rotateMaxSlider,
widthRatioSlider, heightRatioSlider,
natPointsSlider, natDevSlider, natTightSlider,
wavesSlider;
Textfield maxShapeCountBox, opacityBox, lerpFrequencyBox,
maxSizeMultiplierBox, minSizeMultiplierBox,
startBackRBox, startBackGBox, startBackBBox,
startShapeRBox, startShapeGBox, startShapeBBox,
strokeOpacityBox, strokeWidthBox,
borderSizeBox,
rotationMinBox, rotationMaxBox,
widthRatioBox, heightRatioBox,
natPointsBox, natDevBox, natTightBox,
wavesBox,
presetSaveNameBox,
seedBox;
Textlabel triUpLabel, triDownLabel;
ListBox modeList, blendModeList, presetList;
Toggle hsbModeToggle, triUpToggle, triDownToggle;
Button startBackPreview, startShapePreview;

void setup() {
	//INITIALIZE
	fullScreen();
	frameRate(5000);

	PImage icon = loadImage("data/icon_512x512.png");
	PGraphics iconGraphics = createGraphics(512,512,JAVA2D);
	iconGraphics.beginDraw();
	iconGraphics.image(icon,0,0);
	iconGraphics.endDraw();
	surface.setIcon(icon);
	surface.setTitle("ShapeScape v" + loadStrings("data/version.txt")[0]);

	f = new ControlFont(createFont("Arial", 15, true));
	defaultPrefs = loadStrings("data/defaultPrefs.txt");

	docsPath = System.getProperty("user.home") + File.separator + "Documents" + File.separator;

	if (!(new File(docsPath + "ShapeScape")).exists()) {
		(new File(docsPath + "ShapeScape")).mkdir();
	}
	if (!(new File(docsPath + "ShapeScape/presets")).exists()) {
		(new File(docsPath + "ShapeScape/presets")).mkdir();
	}
	if (!(new File(docsPath + "ShapeScape/images")).exists()) {
		(new File(docsPath + "ShapeScape/images")).mkdir();
	}
	if (!(new File(docsPath + "ShapeScape/imageSaveCount.txt")).exists()) {
		saveStrings(docsPath + "ShapeScape/imageSaveCount.txt", new String[] {"0"});
	}

	//GUI INITIALIZE
	cp5 = new ControlP5(this);
	cp5.setFont(f);
	cp5.setColorActive(color(255));
	cp5.setColorBackground(color(150, 150, 150));
	cp5.setColorForeground(color(200, 200, 200));
	Button generateButton = cp5.addButton("drawScape").setPosition(20,20).setSize(120,30).setCaptionLabel("Generate").setColorLabel(color(0, 0, 0));
		seedBox = cp5.addTextfield("_seed").setPosition(140,20).setSize(120,30).setCaptionLabel("").setText("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
		boxes.add(seedBox);
	Button savePrefsButton = cp5.addButton("savePrefs").setPosition(280,20).setSize(120,30).setCaptionLabel("Save Preset").setColorLabel(color(0, 0, 0));
		presetSaveNameBox = cp5.addTextfield("_presetSaveName").setPosition(400,20).setSize(120,30).setCaptionLabel("").setText("newPreset").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
		boxes.add(presetSaveNameBox);
	Button loadPrefsButton = cp5.addButton("loadPrefs").setPosition(540,20).setSize(120,30).setCaptionLabel("Load Preset").setColorLabel(color(0, 0, 0));
	Button deletePrefsButton = cp5.addButton("delPrefs").setPosition(540,50).setSize(120,30).setCaptionLabel("DEL Preset").setColorLabel(color(0, 0, 0));
		presetList = cp5.addListBox("preset").setPosition(670,20).setSize(200,60).setCaptionLabel("Presets").setValue(0).setBarHeight(30).setItemHeight(30).setType(0)
			.addItems(new String[] {"INITIAL"}).setColorLabel(color(0, 0, 0)).setColorValue(color(0, 0, 0));
	Button loadDefaultPrefsButton = cp5.addButton("loadDefault").setPosition(890,20).setSize(150,30).setCaptionLabel("Load Default").setColorLabel(color(0, 0, 0));

	maxShapeCountSlider = cp5.addSlider("maxShapeCount").setPosition(70,90).setSize(750,30).setCaptionLabel("Max Shape Count").setRange(1,750).setColorValue(color(0));
	maxShapeCountSlider.getValueLabel().setVisible(false);
	maxShapeCountBox = cp5.addTextfield("_maxShapeCount").setPosition(20,90).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setInputFilter(controlP5.Textfield.INTEGER).setColorActive(color(255,0,0));
	boxes.add(maxShapeCountBox);
	opacitySlider = cp5.addSlider("opacity").setPosition(70,130).setSize(300,30).setCaptionLabel("Opacity").setRange(0,255).setColorValue(color(0, 0, 0));
	opacitySlider.getValueLabel().setVisible(false);
	opacityBox = cp5.addTextfield("_opacity").setPosition(20,130).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setInputFilter(controlP5.Textfield.INTEGER).setColorActive(color(255,0,0));
	boxes.add(opacityBox);
	lerpFrequencySlider = cp5.addSlider("lerpFrequency").setPosition(70,170).setSize(300,30).setCaptionLabel("Color Lerp Frequency").setRange(0,255).setColorValue(color(0, 0, 0));
	lerpFrequencySlider.getValueLabel().setVisible(false);
	lerpFrequencyBox = cp5.addTextfield("_lerpFrequency").setPosition(20,170).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setInputFilter(controlP5.Textfield.INTEGER).setColorActive(color(255,0,0));
	boxes.add(lerpFrequencyBox);

	startBackRSlider = cp5.addSlider("startBackR").setPosition(70,210).setSize(300,30).setCaptionLabel("Back Red").setRange(-1,255).setColorValue(color(0, 0, 0));
	startBackRSlider.getValueLabel().setVisible(false);
	startBackRBox = cp5.addTextfield("_startBackR").setPosition(20,210).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(startBackRBox);
	startBackGSlider = cp5.addSlider("startBackG").setPosition(70,240).setSize(300,30).setCaptionLabel("Back Green").setRange(-1,255).setColorValue(color(0, 0, 0));
	startBackGSlider.getValueLabel().setVisible(false);
	startBackGBox = cp5.addTextfield("_startBackG").setPosition(20,240).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(startBackGBox);
	startBackBSlider = cp5.addSlider("startBackB").setPosition(70,270).setSize(300,30).setCaptionLabel("Back Blue").setRange(-1,255).setColorValue(color(0, 0, 0));
	startBackBSlider.getValueLabel().setVisible(false);
	startBackBBox = cp5.addTextfield("_startBackB").setPosition(20,270).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(startBackBBox);
	startBackPreview = cp5.addButton("startingPreview").setPosition(550,210).setSize(90,90).setCaptionLabel("Back\nColor").setColorBackground(color(0)).setLock(true).setColorValue(color(0, 0, 0));

	startShapeRSlider = cp5.addSlider("startShapeR").setPosition(70,310).setSize(300,30).setCaptionLabel("Shape Red").setRange(-1,255).setColorValue(color(0, 0, 0));
	startShapeRSlider.getValueLabel().setVisible(false);
	startShapeRBox = cp5.addTextfield("_startShapeR").setPosition(20,310).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(startShapeRBox);
	startShapeGSlider = cp5.addSlider("startShapeG").setPosition(70,340).setSize(300,30).setCaptionLabel("Shape Green").setRange(-1,255).setColorValue(color(0, 0, 0));
	startShapeGSlider.getValueLabel().setVisible(false);
	startShapeGBox = cp5.addTextfield("_startShapeG").setPosition(20,340).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(startShapeGBox);
	startShapeBSlider = cp5.addSlider("startShapeB").setPosition(70,370).setSize(300,30).setCaptionLabel("Shape Blue").setRange(-1,255).setColorValue(color(0, 0, 0));
	startShapeBSlider.getValueLabel().setVisible(false);
	startShapeBBox = cp5.addTextfield("_startShapeB").setPosition(20,370).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(startShapeBBox);
	startShapePreview = cp5.addButton("startingShapePreview").setPosition(550,310).setSize(90,90).setCaptionLabel("Start\nColor").setColorBackground(color(0)).setLock(true).setColorValue(color(0, 0, 0));

	minSizeMultiplierSlider = cp5.addSlider("minSizeMultiplier").setPosition(70,410).setSize(300,30).setLabel("Minimum Size Percent").setRange(0,1).setColorValue(color(0, 0, 0));
	minSizeMultiplierSlider.getValueLabel().setVisible(false);
	minSizeMultiplierBox = cp5.addTextfield("_minSizeMultiplier").setPosition(20,410).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setInputFilter(controlP5.Textfield.FLOAT).setColorActive(color(255,0,0));
	boxes.add(minSizeMultiplierBox);
	maxSizeMultiplierSlider = cp5.addSlider("maxSizeMultiplier").setPosition(70,440).setSize(300,30).setCaptionLabel("Maximum Size Percent").setRange(0,1).setColorValue(color(0, 0, 0));
	maxSizeMultiplierSlider.getValueLabel().setVisible(false);
	maxSizeMultiplierBox = cp5.addTextfield("_maxSizeMultiplier").setPosition(20,440).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setInputFilter(controlP5.Textfield.FLOAT).setColorActive(color(255,0,0));
	boxes.add(maxSizeMultiplierBox);

	widthRatioSlider = cp5.addSlider("widthRatio").setPosition(70,480).setSize(300,30).setLabel("Width Ratio").setRange(-.01,1).setColorValue(color(0, 0, 0));
	widthRatioSlider.getValueLabel().setVisible(false);
	widthRatioBox = cp5.addTextfield("_widthRatio").setPosition(20,480).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(widthRatioBox);
	heightRatioSlider = cp5.addSlider("heightRatio").setPosition(70,510).setSize(300,30).setLabel("Height Ratio").setRange(-.01,1).setColorValue(color(0, 0, 0));
	heightRatioSlider.getValueLabel().setVisible(false);
	heightRatioBox = cp5.addTextfield("_heightRatio").setPosition(20,510).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(heightRatioBox);

	strokeOpacitySlider = cp5.addSlider("strokeOpacity").setPosition(70,550).setSize(300,30).setCaptionLabel("Stroke Opacity").setRange(0,255).setColorValue(color(0, 0, 0));
	strokeOpacitySlider.getValueLabel().setVisible(false);
	strokeOpacityBox = cp5.addTextfield("_strokeOpacity").setPosition(20,550).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setInputFilter(controlP5.Textfield.FLOAT).setColorActive(color(255,0,0));
	boxes.add(strokeOpacityBox);
	strokeWidthSlider = cp5.addSlider("strokeWidth").setPosition(70,580).setSize(300,30).setCaptionLabel("Stroke Width").setRange(0,20).setColorValue(color(0, 0, 0));
	strokeWidthSlider.getValueLabel().setVisible(false);
	strokeWidthBox = cp5.addTextfield("_strokeWidth").setPosition(20,580).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setInputFilter(controlP5.Textfield.FLOAT).setColorActive(color(255,0,0));
	boxes.add(strokeWidthBox);
	borderSizeSlider = cp5.addSlider("borderSize").setPosition(70,620).setSize(300,30).setCaptionLabel("Border Size").setRange(-300,300).setColorValue(color(0, 0, 0));
	borderSizeSlider.getValueLabel().setVisible(false);
	borderSizeBox = cp5.addTextfield("_borderSize").setPosition(20,620).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(borderSizeBox);
	rotateMinSlider = cp5.addSlider("rotateMin").setPosition(70,660).setSize(300,30).setCaptionLabel("Min Rotation").setRange(-180,180).setColorValue(color(0, 0, 0));
	rotateMinSlider.getValueLabel().setVisible(false);
	rotationMinBox = cp5.addTextfield("_rotateMin").setPosition(20,660).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(rotationMinBox);
	rotateMaxSlider = cp5.addSlider("rotateMax").setPosition(70,690).setSize(300,30).setCaptionLabel("Max Rotation").setRange(-180,180).setColorValue(color(0, 0, 0));
	rotateMaxSlider.getValueLabel().setVisible(false);
	rotationMaxBox = cp5.addTextfield("_rotateMax").setPosition(20,690).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(rotationMaxBox);

	blendModeList = cp5.addListBox("currentBlendMode").setPosition(650,140).setSize(300,240).setCaptionLabel("Blending Mode").setBarHeight(30).setItemHeight(30).setType(0)
		.addItems(new String[] {"Blend", "Difference", "Exclusion", "Multiply", "Darkest", "Lightest", "Screen"}).setColorLabel(color(0, 0, 0)).setColorValue(color(0, 0, 0));
	modeList = cp5.addListBox("currentShape").setPosition(960,140).setSize(300,300).setCaptionLabel("Shape Mode").setBarHeight(30).setItemHeight(30).setType(0)
		.addItems(new String[] {"Rectangle", "Ellipse", "Diamond", "Triangle", "Quadrilateral", "Hexagon", "Cube", "Wave", "Octagon"}).setColorLabel(color(0, 0, 0)).setColorValue(color(0, 0, 0));

	natPointsSlider = cp5.addSlider("natPoints").setPosition(70,730).setSize(300,30).setCaptionLabel("Waver").setRange(0,20).setColorValue(color(0, 0, 0));
	natPointsSlider.getValueLabel().setVisible(false);
	natPointsBox = cp5.addTextfield("_natPoints").setPosition(20,730).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(natPointsBox);

	natDevSlider = cp5.addSlider("natDev").setPosition(70,760).setSize(300,30).setCaptionLabel("Waver Severity").setRange(0,30).setColorValue(color(0, 0, 0));
	natDevSlider.getValueLabel().setVisible(false);
	natDevBox = cp5.addTextfield("_natDev").setPosition(20,760).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(natDevBox);

	natTightSlider = cp5.addSlider("natTight").setPosition(70,790).setSize(300,30).setCaptionLabel("Waver Tightness").setRange(-10,10).setColorValue(color(0, 0, 0));
	natTightSlider.getValueLabel().setVisible(false);
	natTightBox = cp5.addTextfield("_natTight").setPosition(20,790).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(natTightBox);

	hsbModeToggle = cp5.addToggle("hsbMode").setPosition(20,830).setSize(30,30).setCaptionLabel("");
		Textlabel toggleLabel = cp5.addTextlabel("Caption").setPosition(51, 832).setText("HSB MODE");

	wavesSlider = cp5.addSlider("waves").setPosition(700,450).setSize(300,30).setCaptionLabel("Waviness").setRange(1,20).setColorValue(color(0, 0, 0));
	wavesSlider.getValueLabel().setVisible(false);
	wavesBox = cp5.addTextfield("_waves").setPosition(650,450).setSize(50,30).setCaptionLabel("").setColorValue(color(0,0,0)).setColorActive(color(255,0,0));
	boxes.add(wavesBox);

	triUpToggle = cp5.addToggle("triUp").setPosition(650,490).setSize(30,30).setCaptionLabel("");
	triUpLabel = cp5.addTextlabel("_1").setPosition(681, 492).setText("Toggle + Tri");
	triDownToggle = cp5.addToggle("triDown").setPosition(825,490).setSize(30,30).setCaptionLabel("");
	triDownLabel = cp5.addTextlabel("_2").setPosition(856, 492).setText("Toggle - Tri");

	cp5.hide();
	//CONTINUE INITIALIZE
	loadDefault();
	updatePresetList();

	if (currentShape == 7) { //Sine
		wavesSlider.show();
		wavesBox.show();
		triUpToggle.hide();
		triDownToggle.hide();
		triUpLabel.setText("Toggle + Waves");
		triDownLabel.setText("Toggle - Waves");
	} else if (currentShape == 3) { //Tri
		wavesSlider.hide();
		wavesBox.hide();
		triUpToggle.show();
		triDownToggle.show();
		triUpLabel.setText("Toggle + Tris");
		triDownLabel.setText("Toggle - Tris");
	} else {
		wavesSlider.hide();
		wavesBox.hide();
		triUpToggle.hide();
		triDownToggle.hide();
		triUpLabel.hide();
		triDownLabel.hide();
	}

	drawScape();
}

void draw() {
	if (guiState) {
		boxesVis.clear();
		for (Textfield t : boxes) {
			if (t.isVisible()) {
				boxesVis.add(t);
			}
		}

		updateColorPickers();

		loneBoxManage(seedBox);
		loneBoxManage(presetSaveNameBox);
		maxShapeCount = (int)boxSliderBalance(maxShapeCount, maxShapeCountBox, maxShapeCountSlider, 0);
		opacity = (int)boxSliderBalance(opacity, opacityBox, opacitySlider, 0);
		lerpFrequency = (int)boxSliderBalance(lerpFrequency, lerpFrequencyBox, lerpFrequencySlider, 0);
		startBackR = (int)boxSliderBalance(startBackR, startBackRBox, startBackRSlider, 0);
		startBackG = (int)boxSliderBalance(startBackG, startBackGBox, startBackGSlider, 0);
		startBackB = (int)boxSliderBalance(startBackB, startBackBBox, startBackBSlider, 0);
		startShapeR = (int)boxSliderBalance(startShapeR, startShapeRBox, startShapeRSlider, 0);
		startShapeG = (int)boxSliderBalance(startShapeG, startShapeGBox, startShapeGSlider, 0);
		startShapeB = (int)boxSliderBalance(startShapeB, startShapeBBox, startShapeBSlider, 0);
		minSizeMultiplier = boxSliderBalance(minSizeMultiplier, minSizeMultiplierBox, minSizeMultiplierSlider, 2);
		maxSizeMultiplier = boxSliderBalance(maxSizeMultiplier, maxSizeMultiplierBox, maxSizeMultiplierSlider, 2);
		widthRatio = boxSliderBalance(widthRatio, widthRatioBox, widthRatioSlider, 2);
		heightRatio = boxSliderBalance(heightRatio, heightRatioBox, heightRatioSlider, 2);
		strokeOpacity = (int)boxSliderBalance(strokeOpacity, strokeOpacityBox, strokeOpacitySlider, 0);
		strokeWidth = boxSliderBalance(strokeWidth, strokeWidthBox, strokeWidthSlider, 2);
		borderSize = (int)boxSliderBalance(borderSize, borderSizeBox, borderSizeSlider, 0);
		rotateMin = (int)boxSliderBalance(rotateMin, rotationMinBox, rotateMinSlider, 0);
		rotateMax = (int)boxSliderBalance(rotateMax, rotationMaxBox, rotateMaxSlider, 0);
		natPoints = (int)boxSliderBalance(natPoints, natPointsBox, natPointsSlider, 0);
		natDev = boxSliderBalance(natDev, natDevBox, natDevSlider, 1);
		natTight = boxSliderBalance(natTight, natTightBox, natTightSlider, 2);
		waves = (int)boxSliderBalance(waves, wavesBox, wavesSlider, 0);

		minMaxLock(minSizeMultiplierSlider, maxSizeMultiplierSlider);
		minMaxLock(rotateMinSlider, rotateMaxSlider);

		if (lastShape != currentShape) {
			if (currentShape == 5 && lastShape != 6 || currentShape == 6 && lastShape != 5) {
				widthRatioSlider.setValue(.83);
				heightRatioSlider.setValue(1);
			}

			if (currentShape == 7) { //Sine
				wavesSlider.show();
				wavesBox.show();
				triUpToggle.show();
				triDownToggle.show();
				triUpLabel.setText("Toggle + Wave");
				triDownLabel.setText("Toggle - Wave");
				triUpLabel.show();
				triDownLabel.show();
				image(raster, 0, 0);
				toggleGUI(true);
			} else if (currentShape == 3) { //Tri
				wavesSlider.hide();
				wavesBox.hide();
				triUpToggle.show();
				triDownToggle.show();
				triUpLabel.setText("Toggle + Tri");
				triDownLabel.setText("Toggle - Tri");
				triUpLabel.show();
				triDownLabel.show();
				image(raster, 0, 0);
				toggleGUI(true);
			} else {
				wavesSlider.hide();
				wavesBox.hide();
				triUpToggle.hide();
				triDownToggle.hide();
				triUpLabel.hide();
				triDownLabel.hide();
				image(raster, 0, 0);
				toggleGUI(true);
			}
			lastShape = currentShape;
		}

		if (triUp && triDown || triUp && !triDown || !triUp && triDown) {
			lastUp = triUp;
			lastDown = triDown;
		} else if (!triUp && !triDown && lastUp && !lastDown) {
			triDownToggle.setValue(true);
		} else if (!triUp && !triDown && !lastUp && lastDown) {
			triUpToggle.setValue(true);
		}
	}
}

void drawScape() {
	imageSaveCount = loadStrings(docsPath + "ShapeScape/imageSaveCount.txt");
	if (seedBox.getText().compareTo("") == 0) {
		seed = "" + int(unaffectedRandomRange(0, 999999999));
		while (seed.length() < 10) {
			seed = "0" + seed;
		}
		seedBox.setText(seed);
	} else {
		seed = seedBox.getText();
	}
	if (!prevSeeds.contains(seed)) {
		undoAmount = 1;
		prevSeeds.add(seed);
	}
	if (prevSeeds.size() > 99) prevSeeds.remove(0);
	randomSeed(seed.hashCode());
	clearEmptyFiles();
	beginRecord(PDF, docsPath + "ShapeScape/images/ShapeScape-" + int(imageSaveCount[0]) + ".pdf");
	blendMode(BLEND);
	colorMode((hsbMode)? HSB:RGB);
	ellipseMode(CORNERS);
	curveTightness(natTight);

	toggleGUI(false);
	if (startBackR < 0 && startBackG < 0 && startBackB < 0 && startShapeR < 0 && startShapeG < 0 && startShapeB < 0) {
		randomShapeR = random(0,255);
		randomShapeG = random(0,255);
		randomShapeB = random(0,255);
		background(randomShapeR, randomShapeG, randomShapeB);
	} else if (startBackR < 0 && startBackG < 0 && startBackB < 0) {
		randomBackR = random(0,255);
		randomBackG = random(0,255);
		randomBackB = random(0,255);
		background(randomBackR, randomBackG, randomBackB);
		randomShapeR = startShapeR;
		randomShapeG = startShapeG;
		randomShapeB = startShapeB;
	} else if (startShapeR < 0 && startShapeG < 0 && startShapeB < 0) {
		background(startBackR, startBackG, startBackB);
		randomShapeR = random(0,255);
		randomShapeG = random(0,255);
		randomShapeB = random(0,255);
	} else {
		background(startBackR, startBackG, startBackB);
		randomShapeR = startShapeR;
		randomShapeG = startShapeG;
		randomShapeB = startShapeB;
	}
	blendMode(correctBlendMode(currentBlendMode));
	for (int i = 0; i < maxShapeCount; i++) {
		currentW = int(random((height + borderSize) * minSizeMultiplier, (height + borderSize) * maxSizeMultiplier));
		currentH = (heightRatio>=0 && widthRatio >= 0)? int(currentW * heightRatio/widthRatio): int(random((height + borderSize) * minSizeMultiplier, (height + borderSize) * maxSizeMultiplier));
		placementX = int(random(-borderSize, width + borderSize - currentW));
		placementY = int(random(-borderSize, height + borderSize - currentH));

		randomShapeR = random(max(0, randomShapeR - lerpFrequency), max(0, randomShapeR + lerpFrequency));
		randomShapeG = random(max(0, randomShapeG - lerpFrequency), max(0, randomShapeG + lerpFrequency));
		randomShapeB = random(max(0, randomShapeB - lerpFrequency), max(0, randomShapeB + lerpFrequency));

		// if (opacity > 0) {
		fill(randomShapeR, randomShapeG, randomShapeB, opacity);
		// } else {
		//     noFill();
		// }

		if (strokeWidth > 0 && strokeOpacity > 0) {
			strokeWeight(strokeWidth);
			stroke(randomShapeR, randomShapeG, randomShapeB, strokeOpacity);
		} else noStroke();

		//ROTATES SHAPES
		pushMatrix();
		translate(placementX + currentW/2, placementY + currentH/2);
		rotate(radians(random(rotateMin, rotateMax)));
		translate(-(placementX + currentW/2), -(placementY + currentH/2));

		switch(currentShape) {
			case 0: rectangle(placementX, placementY, currentW, currentH);
				break;
			case 1: ellipse(placementX, placementY, placementX + currentW, placementY + currentH);
				break;
			case 2: diamond(placementX, placementY, currentW, currentH);
				break;
			case 3:
				if (triUp && triDown) {
					boolean b = getRandomBoolean();
					tri(placementX, placementY, currentW, currentH, b);
				} else if (triUp) {
					tri(placementX, placementY, currentW, currentH, true);
				} else {
					tri(placementX, placementY, currentW, currentH, false);
				}
				break;
			case 4: quadralateral(placementX, placementY, currentW, currentH);
				break;
			case 5: hexagon(placementX, placementY, currentW, currentH);
				break;
			case 6: cube(placementX, placementY, currentW, currentH);
				break;
			case 7:
				if (triUp && triDown) {
					boolean b = getRandomBoolean();
					sine(placementX, placementY, currentW, currentH, b);
				} else if (triUp) {
					sine(placementX, placementY, currentW, currentH, true);
				} else {
					sine(placementX, placementY, currentW, currentH, false);
				}
				break;
			case 8: octagon(placementX, placementY, currentW, currentH);
				break;
		}
		popMatrix();
	}
}

void minMaxLock(Slider minS, Slider maxS) {
	if (minS.getValue() > maxS.getValue() && minS.isInside()) {
		maxS.setValue(minS.getValue());
	} else if (maxS.getValue() < minS.getValue() && maxS.isInside()) {
		minS.setValue(maxS.getValue());
	}
}

void loneBoxManage(Textfield box) {
	for (int i = 0; i < boxesVis.size(); ++i) {
		if (boxesVis.get(i) == box) {
			if (box.isFocus()) {
				currentBoxNum = i;
			} else if (currentBoxNum == i) {
				currentBoxNum = -1;
			}
		}
	}
	if (box.isFocus()) {
		if (cPressed && modPressed) {
		   box.setFocus(false);
		   String t = (box.getText().substring(box.getText().length()-1).toLowerCase().compareTo("c") != 0 && box.getText().substring(box.getText().length()-1).toLowerCase().compareTo("") != 0)? box.getText() : box.getText().substring(0, box.getText().length() - 1);
		   copyString(t);
		   box.setText(t);
		} else if (vPressed && modPressed) {
		   box.setText(pasteString());
		}
	}
}

float boxSliderBalance(float value, Textfield box, Slider slider, int decimals) {
	String s = String.format("%." + decimals + "f", slider.getValue()) + "";

	for (int i = 0; i < boxesVis.size(); i++) {
		if (boxesVis.get(i) == box) {
			if (box.isFocus()) {
				currentBoxNum = i;
			} else if (currentBoxNum == i) {
				currentBoxNum = -1;
			}
		}
	}

	if (!box.isFocus()) {
		box.setText(s);
	} else if (box.isFocus()) {
		if (keyPressed && key == 10) {
			box.setFocus(false);
			box.setText(s);
		} else if (keyPressed && key == 'c' && modPressed) {
			box.setFocus(false);
			String t = (box.getText().substring(box.getText().length()-1).toLowerCase().compareTo("c") != 0)? box.getText() : box.getText().substring(0, box.getText().length() - 1);
			copyString(t);
			box.setText(t);
		} else if (keyPressed && key == 'v' && modPressed) {
			box.setText(pasteString());
			slider.setValue(float(pasteString()));
		} else if (keyPressed) {
			slider.setValue(float(box.getText()));
		}
	}
	return float(box.getText());
}

void goBack() {
	undoAmount++;
	if (prevSeeds.size() - undoAmount >= 0) {
		seedBox.setText(prevSeeds.get(prevSeeds.size() - undoAmount));
		drawScape();
	}
}

void copyString(String string) {
	Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
	StringSelection strSel = new StringSelection(string);
	clipboard.setContents(strSel, null);
}

String pasteString() {
	String str = "";
	try {
		str = (String)Toolkit.getDefaultToolkit().getSystemClipboard().getData(DataFlavor.stringFlavor);
	} catch (UnsupportedFlavorException e) {
		println(e);
	} finally {
		return str;
	}
}

void savePrefs() {
	String st = presetSaveNameBox.getText();
	saveStrings(docsPath + "ShapeScape/presets/" + (st.compareTo("") == 0? "newPreset" : st) + ".txt", new String[] {"" +
		maxShapeCount + "\n" + opacity + "\n" + lerpFrequency + "\n" + startBackR + "\n" + startBackG + "\n" + startBackB + "\n" +
		startShapeR + "\n" + startShapeG + "\n" + startShapeB + "\n" + minSizeMultiplier + "\n" + maxSizeMultiplier + "\n" + widthRatio + "\n" + heightRatio + "\n" + strokeOpacity + "\n" + strokeWidth + "\n" + borderSize + "\n" +
		rotateMin + "\n" + rotateMax + "\n" + currentBlendMode + "\n" + currentShape + "\n" + hsbMode + "\n" + waves + "\n" + triUp + "\n" + triDown + "\n" + natPoints + "\n" + natDev + "\n" + natTight + "\n" + seed + "\n" });
	updatePresetList();
}

void savePrefsPath(String path) {
	saveStrings(path + ".txt", new String[] {"" +
		maxShapeCount + "\n" + opacity + "\n" + lerpFrequency + "\n" + startBackR + "\n" + startBackG + "\n" + startBackB + "\n" +
		startShapeR + "\n" + startShapeG + "\n" + startShapeB + "\n" + minSizeMultiplier + "\n" + maxSizeMultiplier + "\n" + widthRatio + "\n" + heightRatio + "\n" + strokeOpacity + "\n" + strokeWidth + "\n" + borderSize + "\n" +
		rotateMin + "\n" + rotateMax + "\n" + currentBlendMode + "\n" + currentShape + "\n" + hsbMode + "\n" + waves + "\n" + triUp + "\n" + triDown + "\n" + natPoints + "\n" + natDev + "\n" + natTight + "\n" + seed + "\n" });
	updatePresetList();
}

void loadPrefs() {
	if (!presetList.getItems().isEmpty()) {
		prefs = loadStrings(docsPath + "ShapeScape/presets/" + presetList.getItem(preset).entrySet().toArray()[3].toString().replace("text=", "") + ".txt");
		maxShapeCountSlider.setValue(float(prefs[0]));
		opacitySlider.setValue(float(prefs[1]));
		lerpFrequencySlider.setValue(float(prefs[2]));
		startBackRSlider.setValue(float(prefs[3]));
		startBackGSlider.setValue(float(prefs[4]));
		startBackBSlider.setValue(float(prefs[5]));
		startShapeRSlider.setValue(float(prefs[6]));
		startShapeGSlider.setValue(float(prefs[7]));
		startShapeBSlider.setValue(float(prefs[8]));
		minSizeMultiplierSlider.setValue(float(prefs[9]));
		maxSizeMultiplierSlider.setValue(float(prefs[10]));
		widthRatioSlider.setValue(float(prefs[11]));
		heightRatioSlider.setValue(float(prefs[12]));
		strokeOpacitySlider.setValue(float(prefs[13]));
		strokeWidthSlider.setValue(float(prefs[14]));
		borderSizeSlider.setValue(float(prefs[15]));
		rotateMinSlider.setValue(float(prefs[16]));
		rotateMaxSlider.setValue(float(prefs[17]));
		setListOptions(blendModeList, new Integer[] {int(prefs[18])});
		setListOptions(modeList, new Integer[] {int(prefs[19])});
		hsbModeToggle.setValue(boolean(prefs[20]));
		wavesSlider.setValue(float(prefs[21]));
		triUpToggle.setValue(boolean(prefs[22]));
		triDownToggle.setValue(boolean(prefs[23]));
		natPointsSlider.setValue(int(prefs[24]));
		natDevSlider.setValue(float(prefs[25]));
		natTightSlider.setValue(float(prefs[26]));
		seedBox.setText(prefs[27]);
	}
}

void delPrefs() {
	File file = new File (docsPath + "ShapeScape/presets/" + presetList.getItem(preset).entrySet().toArray()[3].toString().replace("text=", "") + ".txt");
	if (file.exists()) {
		file.delete();
	}
	updatePresetList();
}

void loadDefault() {
	maxShapeCountSlider.setValue(float(defaultPrefs[0]));
	opacitySlider.setValue(float(defaultPrefs[1]));
	lerpFrequencySlider.setValue(float(defaultPrefs[2]));
	startBackRSlider.setValue(float(defaultPrefs[3]));
	startBackGSlider.setValue(float(defaultPrefs[4]));
	startBackBSlider.setValue(float(defaultPrefs[5]));
	startShapeRSlider.setValue(float(defaultPrefs[6]));
	startShapeGSlider.setValue(float(defaultPrefs[7]));
	startShapeBSlider.setValue(float(defaultPrefs[8]));
	minSizeMultiplierSlider.setValue(float(defaultPrefs[9]));
	maxSizeMultiplierSlider.setValue(float(defaultPrefs[10]));
	widthRatioSlider.setValue(float(defaultPrefs[11]));
	heightRatioSlider.setValue(float(defaultPrefs[12]));
	strokeOpacitySlider.setValue(float(defaultPrefs[13]));
	strokeWidthSlider.setValue(float(defaultPrefs[14]));
	borderSizeSlider.setValue(float(defaultPrefs[15]));
	rotateMinSlider.setValue(float(defaultPrefs[16]));
	rotateMaxSlider.setValue(float(defaultPrefs[17]));
	setListOptions(blendModeList, new Integer[] {int(defaultPrefs[18])});
	setListOptions(modeList, new Integer[] {int(defaultPrefs[19])});
	hsbModeToggle.setValue(boolean(defaultPrefs[20]));
	wavesSlider.setValue(float(defaultPrefs[21]));
	triUpToggle.setValue(boolean(defaultPrefs[22]));
	triDownToggle.setValue(boolean(defaultPrefs[23]));
	natPointsSlider.setValue(int(defaultPrefs[24]));
	natDevSlider.setValue(float(defaultPrefs[25]));
	natTightSlider.setValue(float(defaultPrefs[26]));
}

void keyReleased() {
	if (key == CODED && (keyCode == 157 || keyCode == CONTROL) && modPressed) {
		modPressed = false;
	} else if ((key == 'c' || keyCode == 67) && cPressed) {
		cPressed = false;
	} else  if ((key == 'v' || keyCode == 86) && vPressed) {
		vPressed = false;
	}
}

void keyPressed() {
	if (key == CODED && (keyCode == 157 || keyCode == CONTROL) && !modPressed) {
		modPressed = true;
	} else if ((key == 'c' || keyCode == 67) && !cPressed) {
		cPressed = true;
	} else  if ((key == 'v' || keyCode == 86) && !vPressed) {
		vPressed = true;
	}

	if (key == CODED) {
		if (keyCode == UP) {
			imageSaveCount = loadStrings(docsPath + "ShapeScape/imageSaveCount.txt");
			if (guiState) {
				toggleGUI(false);
				drawScape();
				//save as vector PDF
				endRecord();
				File pdf = new File(docsPath + "ShapeScape/images/ShapeScape-" + int(imageSaveCount[0]) + ".pdf");
				changeBlendModePDF(pdf, correctBlendModePDF(currentBlendMode));
        //below is code to save as jpg if desired.
        //save(docsPath + "ShapeScape/images/ShapeScape-" + int(imageSaveCount[0]) + ".jpg");
				savePrefsPath(docsPath + "ShapeScape/images/ShapeScape-" + int(imageSaveCount[0]) + "-PRESET");
				toggleGUI(true);
			} else {
				//save as vector PDF
				endRecord();
				File pdf = new File(docsPath + "ShapeScape/images/ShapeScape-" + int(imageSaveCount[0]) + ".pdf");
				changeBlendModePDF(pdf, correctBlendModePDF(currentBlendMode));
        //below is code to save as jpg if desired.
				//save(docsPath + "ShapeScape/images/ShapeScape-" + int(imageSaveCount[0]) + ".jpg");
				savePrefsPath(docsPath + "ShapeScape/images/ShapeScape-" + int(imageSaveCount[0]) + "-PRESET");
			}
			saveStrings(docsPath + "ShapeScape/imageSaveCount.txt", new String[] {"" + (int(imageSaveCount[0]) + 1)});
		} else if (keyCode == LEFT) {
			toggleGUI(!guiState);
			if (!guiState) {
				drawScape();
			}
		} else if (keyCode == RIGHT) {
			seedBox.setText("");
			drawScape();
		} else if (keyCode == DOWN) {
			goBack();
		}
	} else if (key == TAB && guiState) {
		if (currentBoxNum < 0) {
			boxesVis.get(0).setFocus(true);
		} else if (currentBoxNum >= boxesVis.size() - 1) {
			boxesVis.get(boxesVis.size()-1).setFocus(false);
		} else {
			boxesVis.get(currentBoxNum).setFocus(false);
			boxesVis.get(currentBoxNum + 1).setFocus(true);
		}
	} else if (key == ESC) {
		key = 0;
		clearEmptyFiles();
		exit();
	}
}

void updateColorPickers() {
	startBackPreview.setColorBackground(color(startBackR, startBackG, startBackB));
	startShapePreview.setColorBackground(blendColor(color(startBackR, startBackG, startBackB), color(startShapeR, startShapeG, startShapeB, opacity), correctBlendMode(currentBlendMode)));

	if (hsbMode) {
		startBackRSlider.setColorForeground(color(startBackR, 255, 255)).setColorActive(color(startBackR, 255, 255));//.setColorValue(int(startBackR < 0? 0 : startBackR));
		startBackGSlider.setColorForeground(color(startBackR, startBackG, 255)).setColorActive(color(startBackR, startBackG, 255));//.setColorValue(int(startBackG < 0? 0 : startBackG));
		startBackBSlider.setColorForeground(color(startBackR, 255, startBackB)).setColorActive(color(startBackR, 255, startBackB));//.setColorValue(int(255 - (startBackB < 0? 0 : startBackB)));

		startShapeRSlider.setColorForeground(color(startShapeR, 255, 255)).setColorActive(color(startShapeR, 255, 255));//.setColorValue(int(startShapeR < 0? 0 : startShapeR));
		startShapeGSlider.setColorForeground(color(startShapeR, startShapeG, 255)).setColorActive(color(startShapeR, startShapeG, 255));//.setColorValue(int(startShapeG < 0? 0 : startShapeG));
		startShapeBSlider.setColorForeground(color(startShapeR, 255, startShapeB)).setColorActive(color(startShapeR, 255, startShapeB));//.setColorValue(int(255 - (startShapeB < 0? 0 : startShapeB)));
	} else {
		startBackRSlider.setColorForeground(color(startBackR, 0, 0)).setColorActive(color(startBackR, 0, 0));//.setColorValue(int(255 - (startBackR < 0? 0 : startBackR)));
		startBackGSlider.setColorForeground(color(0, startBackG, 0)).setColorActive(color(0, startBackG, 0));//.setColorValue(int(255 - (startBackG < 0? 0 : startBackG)));
		startBackBSlider.setColorForeground(color(0, 0, startBackB)).setColorActive(color(0, 0, startBackB));//.setColorValue(int(255 - (startBackB < 0? 0 : startBackB)));

		startShapeRSlider.setColorForeground(color(startShapeR, 0, 0)).setColorActive(color(startShapeR, 0, 0));//.setColorValue(int(255 - (startShapeR < 0? 0 : startShapeR)));
		startShapeGSlider.setColorForeground(color(0, startShapeG, 0)).setColorActive(color(0, startShapeG, 0));//.setColorValue(int(255 - (startShapeG < 0? 0 : startShapeG)));
		startShapeBSlider.setColorForeground(color(0, 0, startShapeB)).setColorActive(color(0, 0, startShapeB));//.setColorValue(int(255 - (startShapeB < 0? 0 : startShapeB)));
	}

	if (hsbMode && !hsbLabeled) {
		startBackRSlider.setCaptionLabel("Back Hue");
		startBackGSlider.setCaptionLabel("Back Saturation");
		startBackBSlider.setCaptionLabel("Back Brightness");
		startShapeRSlider.setCaptionLabel("Shape Hue");
		startShapeGSlider.setCaptionLabel("Shape Saturation");
		startShapeBSlider.setCaptionLabel("Shape Brightness");
		image(raster, 0, 0);
		toggleGUI(true);
		hsbLabeled = true;
	} else if (!hsbMode && hsbLabeled) {
		startBackRSlider.setCaptionLabel("Back Red");
		startBackGSlider.setCaptionLabel("Back Green");
		startBackBSlider.setCaptionLabel("Back Blue");
		startShapeRSlider.setCaptionLabel("Shape Red");
		startShapeGSlider.setCaptionLabel("Shape Green");
		startShapeBSlider.setCaptionLabel("Shape Blue");
		image(raster, 0, 0);
		toggleGUI(true);
		hsbLabeled = false;
	}
}

void updatePresetList() {
	File dir = new File (docsPath + "ShapeScape/presets/");
	presetList.clear();
	if (!dir.exists()) {
		dir.mkdir();
	} else if (dir.listFiles() != null) {
		File[] files = dir.listFiles();
		for (int i = 0; i < files.length; ++i) {
			presetList.addItems(new String[] {stripExtension(files[i].getName())});
		}
	}
}

void toggleGUI(boolean state) {
	if (state) {
		blendMode(BLEND);
		raster = get();
		fill(0, 70);
		noStroke();
		rect(0, 0, width, height);
		cp5.show();
	} else {
		cp5.hide();
	}
	for (Textfield t : boxes) {
		t.setFocus(false);
	}
	guiState = state;
}

void setListOptions(ListBox list, Integer[] indexes) {
	for (int i = 0; i < list.getItems().size(); i++) {
		list.getItem(i).put("state", false);
	}
	for (int in : indexes) {
		list.getItem(in).put("state", true);
	}
}

int correctBlendMode(int varMode) {
	switch(varMode) {
		case 0:
			return BLEND;
		case 1:
			return DIFFERENCE;
		case 2:
			return EXCLUSION;
		case 3:
			return MULTIPLY;
		case 4:
			return DARKEST;
		case 5:
			return LIGHTEST;
		case 6:
			return SCREEN;
		default:
			return BLEND;
	}
}

COSName correctBlendModePDF(int varMode) {
	switch(varMode) {
		case 0:
			return COSName.NORMAL;
		case 1:
			return COSName.DIFFERENCE;
		case 2:
			return COSName.EXCLUSION;
		case 3:
			return COSName.MULTIPLY;
		case 4:
			return COSName.DARKEN;
		case 5:
			return COSName.LIGHTEN;
		case 6:
			return COSName.SCREEN;
		default:
			return COSName.NORMAL;
	}
}

void changeBlendModePDF(File pdf, COSName bm) {
	PDDocument doc = null; //Instantiates a PDDocument object
	try {
		doc = PDDocument.load(pdf); //Loads our pdf
		PDPage page = (PDPage) doc.getPage(0);	//Gets the page inside of the PDF document. Assumes your PDF has a single page.
		for (COSName c : page.getResources().getExtGStateNames()) { //Foreach of the graphics states...
			page.getResources().getExtGState(c).getCOSObject().setItem(COSName.BM, bm); //Change the blend mode
		}
		doc.removePage(0); //Deletes the old first page
		doc.addPage(page); //Adds in our modified page with changed blend mode
		doc.save(pdf); //Saves the document to the same file location
		println("done");
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		if (doc != null) {
			try {
				doc.close();
			} catch (IOException e) {
				println("Problem when closing doc: " + e.getMessage());
			}
		}
	}
}

void rectangle(float x, float y, float w, float h) {
	beginShape();
	natLine(new pointData(x,y), new pointData(x+w,y), natPoints, natDev);
	natLine(new pointData(x+w,y), new pointData(x+w,y+h), natPoints, natDev);
	natLine(new pointData(x+w,y+h), new pointData(x,y+h), natPoints, natDev);
	natLine(new pointData(x,y+h), new pointData(x,y), natPoints, natDev);
	endShape(CLOSE);
}

void diamond(float x, float y, float w, float h) {
	beginShape();
	natLine(new pointData(x + w/2,y), new pointData(x + w, y + h/2), natPoints, natDev);
	natLine(new pointData(x + w, y + h/2), new pointData(x + w/2,y + h), natPoints, natDev);
	natLine(new pointData(x + w/2,y + h), new pointData(x, y + h/2), natPoints, natDev);
	natLine(new pointData(x, y + h/2), new pointData(x + w/2,y), natPoints, natDev);
	endShape(CLOSE);
}

void tri(float x, float y, float w, float h, boolean up) {
	// boolean b = getRandomBoolean();
	if (up) {
		beginShape();
		natLine(new pointData(x + w/2,y), new pointData(x, y + h), natPoints, natDev);
		natLine(new pointData(x, y + h), new pointData(x + w,y + h), natPoints, natDev);
		natLine(new pointData(x + w,y + h), new pointData(x + w/2,y), natPoints, natDev);
		endShape(CLOSE);
	} else {
		beginShape();
		natLine(new pointData(x + w/2,y + h), new pointData(x + w, y), natPoints, natDev);
		natLine(new pointData(x + w, y), new pointData(x,y), natPoints, natDev);
		natLine(new pointData(x,y), new pointData(x + w/2,y + h), natPoints, natDev);
		endShape(CLOSE);
	}
}

void quadralateral(float x, float y, float w, float h) {
	beginShape();
	pointData p1 = new pointData(random(x, x + w), y);
	pointData p2 = new pointData(x, random(y, y + h));
	pointData p3 = new pointData(random(x, x + w),y + h);
	pointData p4 = new pointData(x + w, random(y, y + h));
	natLine(p1, p2, natPoints, natDev);
	natLine(p2, p3, natPoints, natDev);
	natLine(p3, p4, natPoints, natDev);
	natLine(p4, p1, natPoints, natDev);
	endShape(CLOSE);
}

void hexagon(float x, float y, float w, float h) {
	beginShape();
	natLine(new pointData(x + w/2, y), new pointData(x + w, y + (h/2)*cos(radians(60))), natPoints, natDev);
	natLine(new pointData(x + w, y + (h/2)*cos(radians(60))), new pointData(x + w, y + h - (h/2)*cos(radians(60))), natPoints, natDev);
	natLine(new pointData(x + w, y + h - (h/2)*cos(radians(60))), new pointData(x + w/2, y + h), natPoints, natDev);
	natLine(new pointData(x + w/2, y + h), new pointData(x, y + h - (h/2)*cos(radians(60))), natPoints, natDev);
	natLine(new pointData(x, y + h - (h/2)*cos(radians(60))), new pointData(x, y + (h/2)*cos(radians(60))), natPoints, natDev);
	natLine(new pointData(x, y + (h/2)*cos(radians(60))), new pointData(x + w/2, y), natPoints, natDev);
	endShape(CLOSE);
}

void cube(float x, float y, float w, float h) {
	hexagon(x, y, w, h);

	fill(randomShapeR, randomShapeG, randomShapeB, 0);

	beginShape();
	natLine(new pointData(x, y + (h/2)*cos(radians(60))), new pointData(x + w/2, y + h/2), natPoints, natDev);
	vertex(x + w/2, y + h/2);
	endShape();

	beginShape();
	natLine(new pointData(x + w, y + (h/2)*cos(radians(60))), new pointData(x + w/2, y + h/2), natPoints, natDev);
	vertex(x + w/2, y + h/2);
	endShape();

	beginShape();
	natLine(new pointData(x + w/2, y + h), new pointData(x + w/2, y + h/2), natPoints, natDev);
	vertex(x + w/2, y + h/2);
	endShape();

	// if (opacity > 0) {
		fill(randomShapeR, randomShapeG, randomShapeB, opacity);
	// } else {
	//     noFill();
	// }
}

void sine(float x, float y, float w, float h, boolean positive) {
	if (positive) {
		beginShape();
		curveVertex(x, y + h/2);
		curveVertex(x, y + h/2);
		for (int i = 0; i < waves; i++) {
			curveVertex(x + (w*(i*4+1))/(4*waves), y);
			curveVertex(x + (w*(i*4+3))/(4*waves), y + h);
		}
		curveVertex(x + w, y + h/2);
		curveVertex(x + w, y + h/2);
		endShape();
	} else {
		beginShape();
		curveVertex(x, y + h/2);
		curveVertex(x, y + h/2);
		for (int i = 0; i < waves; i++) {
			curveVertex(x + (w*(i*4+1))/(4*waves), y + h);
			curveVertex(x + (w*(i*4+3))/(4*waves), y);
		}
		curveVertex(x + w, y + h/2);
		curveVertex(x + w, y + h/2);
		endShape();
	}
}

void octagon(float x, float y, float w, float h) {
	beginShape();
	natLine(new pointData(x + w/3, y), new pointData(x + 2*w/3, y), natPoints, natDev);
	natLine(new pointData(x + 2*w/3, y), new pointData(x + w, y + h/3), natPoints, natDev);
	natLine(new pointData(x + w, y + h/3), new pointData(x + w, y + 2*h/3), natPoints, natDev);
	natLine(new pointData(x + w, y + 2*h/3), new pointData(x + 2*w/3, y+h), natPoints, natDev);
	natLine(new pointData(x + 2*w/3, y+h), new pointData(x + w/3, y+h), natPoints, natDev);
	natLine(new pointData(x + w/3, y+h), new pointData(x, y + 2*h/3), natPoints, natDev);
	natLine(new pointData(x, y + 2*h/3), new pointData(x, y + h/3), natPoints, natDev);
	natLine(new pointData(x, y + h/3), new pointData(x + w/3, y), natPoints, natDev);
	endShape(CLOSE);
}

void natLine(pointData a, pointData b, int betPoints, float dev) { //betPoints = between points, how many points of variation are in between the two points, dev is the deviation of the point from the perfect line
	vertex(a.x,a.y);
	curveVertex(a.x,a.y);
	curveVertex(a.x,a.y);
	float length = lineLength(a,b);
	float current = 0; //FIX find min space between points to avoid Z, random between current + min and length, if current + min is greater than length then finish with that side.
	for (int i = 0; i < betPoints; i++) {
		float currentExtra = current + 20 + random(0,length/betPoints);
		if (current + 20 > length || currentExtra > length) {
			break;
		}
		current = random(current + 20, currentExtra);
		pointData distant = pointAlongLine(a, b, (b.x < a.x)? -current : current);
		pointData point = vectorPoint(distant, -1/slope(a,b), random(-dev, dev));
		curveVertex(point.x, point.y);
		// strokeWeight(8);
		// stroke(color(255,0,0));
		// point(point.x, point.y);
		// strokeWeight(0);
		// stroke(color(0,0,0));
	}
}

boolean getRandomBoolean() {
	return random(0,1.0001) < 0.5;
}

void clearEmptyFiles() {
	File dir = new File (docsPath + "ShapeScape/images/");

	if (!dir.exists()) {
		dir.mkdir();
	}

	File[] files = dir.listFiles();
	if (files != null) {
		for (File f : files) {
			if (f.length() == 0) {
				f.delete();
			}
		}
	}
}

float unaffectedRandomRange(float min, float max) {
	float range = max - min;
	return (float)(Math.random() * range + min);
}

String stripExtension (String fileString) {
	return fileString.replace(".txt", "");
}

public class pointData {
	float x, y;

	public pointData(float xVal, float yVal) {
		x = xVal;
		y = yVal;
	}
}

pointData vectorPoint(pointData point, float slope, float distance) {
	return new pointData(point.x + distance * cos(atan(slope)), point.y + distance * sin(atan(slope)));
}

pointData pointAlongLine(pointData a, pointData b, float distance) { //distance is from point a
	return vectorPoint(a, slope(a,b), distance);
}

float lineLength(pointData a, pointData b) {
	return (float)Math.sqrt(Math.pow(b.x - a.x, 2) + Math.pow(b.y - a.y, 2));
}

boolean greaterPoint(pointData a, pointData b) { //is point A greater than point B?
	return (lineLength(new pointData(0,0), a) >= lineLength(new pointData(0,0), b));
}

float slope(pointData a, pointData b) {
	return (b.y-a.y)/(b.x-a.x);
}
