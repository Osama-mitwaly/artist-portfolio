interface ConfirmProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  message: string;
}

export default function ConfirmDialog({ isOpen, onClose, onConfirm, message }: ConfirmProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/30 p-4">
      <div className="bg-white p-6 rounded-lg shadow-xl max-w-sm w-full text-center animate-fade-in">
        <p className="text-ink mb-6">{message}</p>
        <div className="flex gap-4 justify-center">
          <button onClick={onClose} className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-50">إلغاء</button>
          <button onClick={onConfirm} className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700">تأكيد الحذف</button>
        </div>
      </div>
    </div>
  );
}
