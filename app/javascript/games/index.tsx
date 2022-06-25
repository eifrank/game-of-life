import React, { useState, useCallback, useRef } from "react";
import ReactDOM from "react-dom";
import produce from "immer";

const operations = [
  [0, 1],
  [0, -1],
  [1, -1],
  [-1, 1],
  [1, 1],
  [-1, -1],
  [1, 0],
  [-1, 0]
];

function Game(props) {
  
  const generateEmptyGrid = () => {
    const rows = [];
    for (let i = 0; i < props.rows; i++) {
      rows.push(Array.from(Array(props.columns), () => 0));
    }
  
    return rows;
  };

  const [grid, setGrid] = useState(() => {
    return generateEmptyGrid();
  });


  const [running, setRunning] = useState<boolean>(false);

  const runningRef = useRef(running);
  runningRef.current = running;

  const runSimulation = useCallback(() => {
    if (!runningRef.current) {
      return;
    }

    setGrid(g => {
      return produce(g, gridCopy => {
        for (let i = 0; i < props.rows; i++) {
          for (let k = 0; k < props.columns; k++) {

            let neighbors = 0;
            operations.forEach(([x, y]) => {
              const newI = i + x;
              const newK = k + y;
              if (newI >= 0 &&
                  newI < props.rows &&
                  newK >= 0 &&
                  newK < props.columns) {
                neighbors += g[newI][newK];
              }
            });
            
            if (neighbors < 2 || neighbors > 3) {
              gridCopy[i][k] = 0;//die
            } else if (g[i][k] === 0 && neighbors === 3) {
              gridCopy[i][k] = 1;
            }
          }

        }
      });
    });
    setTimeout(runSimulation, 600);
  }, []);

  return (
    <>
      <button
        onClick={() => {
          setRunning(!running);
          if (!running) {
            runningRef.current = true;
            runSimulation();
          }
        }}
      >
        {running ? "stop" : "start"}
      </button>

      <button
        onClick={() => {
          setGrid(generateEmptyGrid());
        }}
      >
        clear
      </button>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: `repeat(${props.columns}, 40px)`
        }}
      >
        {grid.map((rows, i) =>
          rows.map((col, k) => (
            <div
              key={`${i}-${k}`}
              onClick={() => {
                const newGrid = produce(grid, gridCopy => {
                  gridCopy[i][k] = grid[i][k] ? 0 : 1;
                });
                setGrid(newGrid);
              }}
              style={{
                width: 40,
                height: 40,
                backgroundColor: grid[i][k] ? "green" : undefined,
                border: "solid 1px black"
              }}
            />
          ))
        )}
      </div>
    </>
  );
};

const rootElement = document.getElementById('gameOfLife') as HTMLElement;
const conf = JSON.parse(rootElement.dataset.conf as string);

ReactDOM.render(
  <Game  {...conf}/>,
  rootElement
);