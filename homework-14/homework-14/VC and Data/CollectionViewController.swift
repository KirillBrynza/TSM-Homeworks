import UIKit

final class ViewController: UIViewController {

    private let devices = [
        "airpodspro",
        "laptopcomputer",
        "display",
        "applewatch",
        "ipad",
        "iphone"
    ]

    private lazy var collectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            DeviceCell.self,
            forCellWithReuseIdentifier: DeviceCell.identifier
        )

        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            collectionView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        devices.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DeviceCell.identifier,
            for: indexPath
        ) as? DeviceCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: devices[indexPath.item])

        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        CGSize(width: 50, height: 50)
    }
}
