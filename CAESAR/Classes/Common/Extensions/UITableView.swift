// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import UIKit

// MARK: - scrollToBottom

extension UITableView {
  func scrollToBottom(animated: Bool) {
    guard let dataSource = dataSource else { return }
    var lastSectionWithAtLeastOneElement = (dataSource.numberOfSections?(in: self) ?? 1) - 1
    while dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeastOneElement) < 1 && lastSectionWithAtLeastOneElement > 0 {
      lastSectionWithAtLeastOneElement -= 1
    }
    let lastRow = dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeastOneElement) - 1
    guard lastSectionWithAtLeastOneElement > -1 && lastRow > -1 else { return }
    let bottomIndex = IndexPath(item: lastRow, section: lastSectionWithAtLeastOneElement)
    scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
  }
}
