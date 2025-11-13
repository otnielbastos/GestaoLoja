
interface QuantitySelectorProps {
  value: number;
  onChange: (value: number) => void;
  min?: number;
  max?: number;
}

export default function QuantitySelector({ value, onChange, min = 0, max = 99 }: QuantitySelectorProps) {
  const handleDecrease = () => {
    if (value > min) {
      onChange(value - 1);
    }
  };

  const handleIncrease = () => {
    if (value < max) {
      onChange(value + 1);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = parseInt(e.target.value) || 0;
    if (newValue >= min && newValue <= max) {
      onChange(newValue);
    }
  };

  return (
    <div className="flex items-center border border-gray-300 rounded-lg overflow-hidden">
      <button
        type="button"
        onClick={handleDecrease}
        disabled={value <= min}
        className="w-10 h-10 flex items-center justify-center bg-gray-100 hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
      >
        <i className="ri-subtract-line text-gray-600"></i>
      </button>
      <input
        type="number"
        value={value}
        onChange={handleInputChange}
        min={min}
        max={max}
        className="w-16 h-10 text-center border-0 focus:outline-none text-sm"
      />
      <button
        type="button"
        onClick={handleIncrease}
        disabled={value >= max}
        className="w-10 h-10 flex items-center justify-center bg-gray-100 hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
      >
        <i className="ri-add-line text-gray-600"></i>
      </button>
    </div>
  );
}
