import { useState, useEffect } from "react";
import "./Game.css";

function Square({ value, onSquareClick, isWinner }) {
  return (
    <button
      className={`square ${value || ""} ${isWinner ? "winner" : ""}`}
      onClick={onSquareClick}
    >
      {value}
    </button>
  );
}

function Board({ xIsNext, squares, onPlay }) {
  const result = calculateWinner(squares);
  const winner = result?.winner;
  const winningLine = result?.line || [];

  function handleClick(i) {
    if (winner || squares[i]) return;
    const nextSquares = squares.slice();
    nextSquares[i] = xIsNext ? "X" : "O";
    onPlay(nextSquares);
  }

  const status = winner
    ? `🏆 Câștigător: ${winner}`
    : `👉 Următorul jucător: ${xIsNext ? "X" : "O"}`;

  return (
    <div className="board-container">
      <div className="status">{status}</div>
      <div className="board">
        {squares.map((value, i) => (
          <Square
            key={i}
            value={value}
            onSquareClick={() => handleClick(i)}
            isWinner={winningLine.includes(i)}
          />
        ))}
      </div>
    </div>
  );
}

export default function Game() {
  const [history, setHistory] = useState([Array(9).fill(null)]);
  const [currentMove, setCurrentMove] = useState(0);
  const [showConfetti, setShowConfetti] = useState(false);

  const xIsNext = currentMove % 2 === 0;
  const currentSquares = history[currentMove];

  const result = calculateWinner(currentSquares);
  const winner = result?.winner;

  // 👇 declanșăm confetti când apare un câștigător
  useEffect(() => {
    if (winner) {
      setShowConfetti(true);
      const timeout = setTimeout(() => setShowConfetti(false), 4000);
      return () => clearTimeout(timeout);
    }
  }, [winner]);

  function handlePlay(nextSquares) {
    const nextHistory = [...history.slice(0, currentMove + 1), nextSquares];
    setHistory(nextHistory);
    setCurrentMove(nextHistory.length - 1);
  }

  function jumpTo(nextMove) {
    setCurrentMove(nextMove);
  }

  const moves = history.map((_, move) => {
    const description = move ? `Mutarea #${move}` : "Începe jocul";
    return (
      <li key={move}>
        <button
          onClick={() => jumpTo(move)}
          className={`history-btn ${move === currentMove ? "active" : ""}`}
        >
          {description}
        </button>
      </li>
    );
  });

  return (
    <div className="game-page">
      <h1 className="title">🎮 Tic Tac Toe</h1>
      <div className="game">
        <div className="game-board">
          <Board xIsNext={xIsNext} squares={currentSquares} onPlay={handlePlay} />
        </div>
        <div className="game-info">
          <h2>📜 Istoric</h2>
          <ol>{moves}</ol>
        </div>
      </div>
      <button
        className="reset-btn"
        onClick={() => {
          setHistory([Array(9).fill(null)]);
          setCurrentMove(0);
          setShowConfetti(false);
        }}
      >
        🔁 Resetează jocul
      </button>

      {/* 🎊 Efect confetti */}
      {showConfetti && <Confetti />}
    </div>
  );
}

/* Componentă Confetti */
function Confetti() {
  const pieces = Array.from({ length: 80 }); // mai multe bucăți
  return (
    <div className="confetti-container">
      {pieces.map((_, i) => (
        <div
          key={i}
          className="confetti-piece"
          style={{
            left: `${Math.random() * 100}%`,
            backgroundColor: `hsl(${Math.random() * 360}, 100%, 60%)`,
            animationDelay: `${Math.random() * 0.5}s`,
            transform: `rotate(${Math.random() * 360}deg)`,
          }}
        />
      ))}
    </div>
  );
}

/* Verificare câștigător */
function calculateWinner(squares) {
  const lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
  for (let [a, b, c] of lines) {
    if (squares[a] && squares[a] === squares[b] && squares[a] === squares[c]) {
      return { winner: squares[a], line: [a, b, c] };
    }
  }
  return null;
}
