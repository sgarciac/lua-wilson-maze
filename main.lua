NORTH = 0
WEST = 1
SOUTH = 2
EAST = 3

BLOCKED = 0
OPEN = 1

-- Maze ADT

function createMaze(height, width)
	 local maze = {
			height = height,
			width = width,
			cells = {}
	 }
	 for i=0,height do
			maze.cells[i] = {}
			for j=0,width do
				 maze.cells[i][j] = {}
				 maze.cells[i][j][EAST] = i > 0
				 maze.cells[i][j][SOUTH] = j > 0
				 maze.cells[i][j].roomtype = (i > 0 and j > 0) and BLOCKED or OPEN
			end
	 end
	 return maze
end

function hasWall(maze, x, y, direction)
	 if direction == SOUTH or direction == EAST then
			return maze.cells[y+1][x+1][direction]
	 elseif direction == NORTH then
			return maze.cells[y][x+1][SOUTH]
	 elseif direction == WEST then
			return maze.cells[y+1][x][EAST]
	 end
end

function setWall(maze, x, y, direction, wall)
	 if direction == SOUTH or direction == EAST then
			maze.cells[y+1][x+1][direction] = wall
	 elseif direction == NORTH then
			maze.cells[y][x+1][SOUTH] = wall
	 elseif direction == WEST then
			maze.cells[y+1][x][EAST] = wall
	 end
end

function getRoomtype(maze, x, y)
	 return maze.cells[y+1][x+1].roomtype
end

function setRoomtype(maze, x, y, roomtype)
	 maze.cells[y+1][x+1].roomtype = roomtype
end


-- Graphics
function pixel(maze, x, y, cellSize)
	 local localX = x % cellSize
	 local localY = y % cellSize

	 local cellX = math.floor(x / cellSize)
	 local cellY = math.floor(y / cellSize)

	 if(cellX > maze.width or cellY > maze.height) then
			return 0
	 end

	 local cell = maze.cells[cellY][cellX]

	 if cell.roomtype == BLOCKED or (localY == cellSize - 1 and cell[SOUTH]) or (localX == cellSize - 1 and cell[EAST]) then
			return 1
	 else
			return 0
	 end
end

function printMaze(maze, cellSize)
	 print "P1"
	 print (cellSize * (maze.width + 2))
	 print (cellSize * (maze.height + 2))
	 for i=0,(cellSize * (maze.height + 2)) - 1 do
			for j=0,(cellSize * (maze.width + 2)) - 1 do
				 io.write(tostring(pixel(maze, j, i, cellSize)))
			end
			io.write('\n')
	 end
	 io.write('\n')
end

-- Maze generation
function randomNextDirection(maze, x, y)
	 local directions = {}
	 if x > 0 then
			table.insert(directions, WEST)
	 end
	 if x < maze.width - 1 then
			table.insert(directions, EAST)
	 end
	 if y > 0 then
			table.insert(directions, NORTH)
	 end
	 if y < maze.height - 1 then
			table.insert(directions, SOUTH)
	 end
	 return directions[math.random(#directions)]
end

function nextCell(x,y,direction)
	 if direction == NORTH then
			return {x = x, y = y - 1}
	 elseif direction == SOUTH then
			return {x = x, y = y + 1}
	 elseif direction == EAST then
			return {x = x + 1, y = y}
	 else
			return {x = x - 1, y = y}
	 end
end

function getBlockedCells(maze)
	 local blockedCells = {}
	 for i=0,maze.height - 1 do
			for j=0,maze.width - 1 do
				 if getRoomtype(maze, j, i) == BLOCKED then
						table.insert(blockedCells, {x = j, y = i})
				 end
			end
	 end
	 return blockedCells
end

function carveMaze(maze)

	 setRoomtype(maze,math.random(0, maze.width - 1), math.random(0, maze.height - 1), OPEN)
	 local blockedCells = getBlockedCells(maze)

	 while #blockedCells > 0 do
			local startCell = blockedCells[math.random(#blockedCells)]
			local currentCell = startCell

			-- calculate a path
			local path = {}
			while getRoomtype(maze, currentCell.x, currentCell.y) == BLOCKED do
				 local x = currentCell.x
				 local y = currentCell.y
				 local direction = randomNextDirection(maze, x, y)
				 if not path[x] then
						path[x] = {}
				 end
				 path[x][y] = direction
				 currentCell = nextCell(x, y, direction)
			end
			-- clean rooms
			currentCell = startCell
			while getRoomtype(maze, currentCell.x, currentCell.y) == BLOCKED do
				 local x = currentCell.x
				 local y = currentCell.y
				 local direction = path[x][y]
				 setRoomtype(maze, x, y, OPEN)
				 setWall(maze, x, y, direction, false)
				 currentCell = nextCell(x, y, direction)
			end
			blockedCells = getBlockedCells(maze)
	 end
end

-- Main


maze = createMaze(50,50)
carveMaze(maze)
printMaze(maze,20)
