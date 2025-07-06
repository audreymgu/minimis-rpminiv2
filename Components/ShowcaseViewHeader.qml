import QtQuick 2.3
import QtQml.Models 2.10
import QtGraphicalEffects 1.0

ListView {
    id: root

    //height: vpx(33) * ((uiScale ?? 1) < 0 ? 1 : uiScale)
    height: vpx(40) * ((uiScale ?? 1) < 0 ? 1 : uiScale)

    anchors {
        left: parent.left
        right: parent.right
        top: parent.top

        topMargin: height / 2.0
        bottomMargin: height / 2.0
    }

    spacing: vpx(12)

    orientation: ListView.Horizontal
    layoutDirection: Qt.RightToLeft

    signal dropdownUpdated()

    model: ObjectModel {
        Button {
            id: settingsButton
            icon: '\uf013'

            width: root.height; height: root.height
            circle: true

            selected: root.focus && ListView.isCurrentItem

            onActivated: {
                toSettingsView();
            }
        }

        Button {
            id: sortButton
            text: sortDropdown.items[sortDropdown.checkedIndex]

            height: parent.height
            circle: false
            selected: root.focus && ListView.isCurrentItem

            onActivated: { sortDropdown.toggle() }

            Dropdown {
                id: sortDropdown
                focus: parent.selected

                items: ['By Title', 'By Developer', 'By Publisher', 'By Genre', 'By Year', 'By Players', 'By Rating', 'By Last Played']
                checkedIcon: orderByDirection === Qt.AscendingOrder ? '\uf0d8 ' : '\uf0d7 '

                checkedIndex: orderByIndex

                onActivated: (idx) => {
                    if (orderByIndex === idx) {
                        orderByDirection = orderByDirection === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder;
                    } else {
                        orderByIndex = idx;
                        orderByDirection = Qt.AscendingOrder;
                    }

                    root.dropdownUpdated();
                }
            }
        }

        Button {
            id: filterButton
            text: filterDropdownModel.get(filterDropdown.checkedIndex).name

            height: parent.height
            circle: false
            selected: root.focus && ListView.isCurrentItem

            onActivated: { filterDropdown.toggle(); }

            ListModel {
                id: filterDropdownModel

                ListElement { name: 'All Games' }
                ListElement { name: 'Favorites' }
            }

            Dropdown {
                id: filterDropdown
                focus: parent.selected

                items: filterDropdownModel
                roleName: 'name'

                checkedIndex: filterByFavorites ? 1 : 0

                onActivated: (idx) => {
                    if (idx === 0) {
                        filterByFavorites = false;
                    }

                    if (idx === 1) {
                        filterByFavorites = true;
                    }

                    root.dropdownUpdated();
                }
            }
        }

        Button {
            id: collectionsButton
            text: currentCollection.name

            height: parent.height
            circle: false
            selected: root.focus && ListView.isCurrentItem

            onActivated: { collectionsDropdown.toggle(); }

            Dropdown {
                id: collectionsDropdown
                focus: parent.selected

                items: api.collections
                roleName: 'name'

                checkedIndex: currentCollectionIndex
                onActivated: (idx) => {
                    currentCollectionIndex = currentIndex;
                    root.dropdownUpdated();
                }
            }
        }
    }

    Keys.onDownPressed: {
        sfxNav.play();
        showcase.focus = true;
    }

}