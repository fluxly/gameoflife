// Controls:
// LEFT
// ~ : Load small new scene
// ~ : Load larger new scene

// CENTER
// play/pause
// step

// RIGHT
// ? : link to Lifewiki
// exit to menu

var cells = [];
var count = [];
var pageW = 960;
var pageH = 640;
var cellRows = 32;
var cellCols = 48;
var cellW = 20;
var palette = [];
var randomMutation = false;
var playing = false;

function setup(){
	palette = [ 
		color('#000000'), color('#0e65e5'), color('#00aeef'), color('#e7198b'), color('#6400DB'), color('#00D8CB'),
		color('#96ff00'), color('#d802ca'), color('#F5EB00'), color('#fe6b10'), color('#ffffff')
	];
	sceneCanvas = createCanvas(pageW, pageH);
	sceneCanvas.parent('scene-wrapper');
	noStroke();
	rectMode(CENTER);
    newGame();
	frameRate(20);
}

function newGame() {
	randomMutation = false;
	if (random(0, 100) > 70) randomMutation = true;

	let threshold = random(10, 100);

	cells = [];
	count = [];
	for (let i = 0; i < cellCols; i++) {
		cells.push([]);
		count.push([]);
	}
	for (let i = 0; i < cellRows; i++) {
		for (let j = 0; j < cellCols; j++) {
			cells[i].unshift(0);
			count[i].unshift(0);
		}
	}
	
}

function draw(){

	background(0);
	for (let i = 0; i < cellRows; i++) {
		for (let j = 0; j < cellCols; j++) {
			count[i][j] = getNeighborCount(i, j);
		}
	}
	for (let i = 0; i < cellRows; i++) {
		for (let j = 0; j < cellCols; j++) {
			if (playing) {
				if ((cells[i][j] == 0) && (count[i][j] == 3)) cells[i][j] = round(random(1, 9));
				if ((count[i][j] < 2) || (count[i][j] > 3)) cells[i][j] = 0;

				if (cells[i][j] !== 0) {
					fill(palette[cells[i][j]]);
					circle(j*cellW, i*cellW, cellW);
				}
			} else {
				fill(palette[cells[i][j]]);
				circle(j*cellW, i*cellW, cellW);
			}
			
		}
	}
}

function getNeighborCount(row, col) {
    let count = 0; 
	if (row - 1 >= 0) {
		if (cells[row - 1][col] > 0) count++;
	}
	if (row - 1 >= 0 && col - 1 >= 0) {
		if (cells[row - 1][col - 1] > 0) count++;
	}
	if (row - 1 >= 0 && col + 1 < cellCols) {
		if (cells[row - 1][col + 1] > 0) count++;
	}
	if (col - 1 >= 0) {
		if (cells[row][col - 1] > 0) count++;
	}
	if (col + 1 < cellCols) {
		if (cells[row][col + 1] > 0) count++;
	}
	if (row + 1 < cellRows && col - 1 >= 0) {
		if (cells[row + 1][col - 1] > 0) count++;
	}
	if (row + 1 < cellRows && col + 1 <  cellCols) {
		if (cells[row + 1][col + 1] > 0) count++;
	}
	if (row + 1 < cellRows) {
		if (cells[row + 1][col] > 0) count++;
	}
    return count;
}

function touchStarted() {
	let x = Math.round((mouseX / pageW) * cellCols);
	let y = Math.round((mouseY / pageH) * cellRows);
	cells[y][x] = Math.round(random(1, 10));
}
function touchMoved() {
	let x = Math.round((mouseX / pageW) * cellCols);
	let y = Math.round((mouseY / pageH) * cellRows);
	cells[y][x] = Math.round(random(1, 10));
}

function keyPressed() {
	playing = !playing;
}