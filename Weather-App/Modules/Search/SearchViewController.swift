import UIKit

final class SearchViewController: UIViewController,
                                  UITableViewDataSource,
                                  UITableViewDelegate,
                                  UISearchBarDelegate {
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    // докинуть города 
    private let cities = [
        "Минск", "Гомель", "Могилёв", "Витебск", "Гродно",
        "Брест", "Бобруйск", "Барановичи", "Борисов", "Пинск",
        "Орша", "Мозырь", "Солигорск", "Новополоцк", "Лида",
        "Полоцк", "Молодечно", "Жлобин", "Светлогорск", "Речица"
    ]
    
    private let historyKey = "recentCities"
    private let favoritesKey = "favoriteCities"
    
    private var recentCities: [String] = []
    private var favoriteCities: [String] = []
    private var filteredCities: [String] = []
    private var searchText = ""
    
    private enum Section: Int, CaseIterable {
        case favorites
        case recent
        case all
        
        var title: String {
            switch self {
            case .favorites: return "Избранное"
            case .recent: return "Недавние запросы"
            case .all: return "Города Беларуси"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Поиск города"
        view.backgroundColor = .systemBackground
        
        recentCities = UserDefaults.standard.stringArray(
            forKey: historyKey
        ) ?? []
        
        favoriteCities = UserDefaults.standard.stringArray(
            forKey: favoritesKey
        ) ?? []
        
        setupSearchBar()
        setupTableView()
        setupClearHistoryButton()
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Найти город Беларуси"
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .search
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            searchBar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            searchBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: searchBar.bottomAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -60
            )
        ])
    }
    
    private func setupClearHistoryButton() {
        let button = UIButton(type: .system)
        button.setTitle("Очистить историю", for: .normal)
        button.addTarget(
            self,
            action: #selector(clearHistory),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            button.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            button.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -8
            ),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func citiesForSection(_ section: Section) -> [String] {
        if !searchText.isEmpty {
            if section == .all {
                return filteredCities
            }
            return []
        }
        
        switch section {
        case .favorites:
            return favoriteCities
        case .recent:
            return recentCities
        case .all:
            return cities.filter {
                !favoriteCities.contains($0) &&
                !recentCities.contains($0)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        guard let sectionType = Section(rawValue: section) else {
            return nil
        }
        
        let items = citiesForSection(sectionType)
        return items.isEmpty ? nil : sectionType.title
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard let sectionType = Section(rawValue: section) else {
            return 0
        }
        
        return citiesForSection(sectionType).count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = UITableViewCell(
            style: .default,
            reuseIdentifier: "CityCell"
        )
        
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return cell
        }
        
        let items = citiesForSection(sectionType)
        let city = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = city
        cell.contentConfiguration = content
        
        if favoriteCities.contains(city) {
            cell.accessoryView = makeFavoriteButton(for: city)
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    private func makeFavoriteButton(for city: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(
            UIImage(systemName: "star.fill"),
            for: .normal
        )
        button.tintColor = .systemYellow
        button.addAction(
            UIAction { [weak self] _ in
                self?.toggleFavorite(city)
            },
            for: .touchUpInside
        )
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        return button
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return
        }
        
        let items = citiesForSection(sectionType)
        let city = items[indexPath.row]
        
        UserDefaults.standard.set(city, forKey: "selectedCity")
        
        recentCities.removeAll { $0 == city }
        recentCities.insert(city, at: 0)
        recentCities = Array(recentCities.prefix(10))
        
        UserDefaults.standard.set(recentCities, forKey: historyKey)
        
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return nil
        }
        
        let items = citiesForSection(sectionType)
        let city = items[indexPath.row]
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            
            if sectionType == .favorites {
                self.favoriteCities.removeAll { $0 == city }
                UserDefaults.standard.set(
                    self.favoriteCities,
                    forKey: self.favoritesKey
                )
            } else {
                self.recentCities.removeAll { $0 == city }
                UserDefaults.standard.set(
                    self.recentCities,
                    forKey: self.historyKey
                )
            }
            
            self.tableView.reloadData()
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        self.searchText = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        filteredCities = cities.filter {
            $0.localizedCaseInsensitiveContains(self.searchText)
        }
        
        tableView.reloadData()
    }
    
    private func toggleFavorite(_ city: String) {
        if favoriteCities.contains(city) {
            favoriteCities.removeAll { $0 == city }
        } else {
            favoriteCities.insert(city, at: 0)
        }
        
        UserDefaults.standard.set(
            favoriteCities,
            forKey: favoritesKey
        )
        
        tableView.reloadData()
    }
    
    @objc private func clearHistory() {
        let alert = UIAlertController(
            title: "Очистить историю?",
            message: "Недавние запросы будут удалены. Избранное останется.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "Отмена", style: .cancel)
        )
        
        alert.addAction(
            UIAlertAction(title: "Очистить", style: .destructive) {
                [weak self] _ in
                
                guard let self else { return }
                
                self.recentCities.removeAll()
                UserDefaults.standard.removeObject(
                    forKey: self.historyKey
                )
                
                self.tableView.reloadData()
            }
        )
        
        present(alert, animated: true)
    }
}
