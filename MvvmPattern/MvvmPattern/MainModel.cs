using System.ComponentModel;

namespace MvvmPattern
{
    public class MainModel : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        private int _age = 30;

        public int Age
        {
            get => _age;
            set
            {
                if (value != _age)
                {
                    _age = value;
                    PropertyChanged?.Invoke(value, new PropertyChangedEventArgs(nameof(Age)));
                }
            }
        }

        public int MaximumHeartRate
        {
            get
            {
                return 220 - _age;
            }
        }

        public int TargetHeartRate
        {
            get
            {
                return (int)(0.85 * MaximumHeartRate);
            }
        }
    }
}
