//
//  SearchFilterPanel.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 2024-06-12.
//

import Combine
import SwiftUI

/// A search and filter controls panel with debounce, theme, favorites, and waveform density toggles.
struct SearchFilterPanel: View {
    // MARK: - Bindings and Callbacks

    @Binding var searchText: String

    let onSearch: (String) -> Void
    let onToggleTheme: () -> Void
    let onToggleFavorites: () -> Void
    let onWaveformDensity: (Int) -> Void

    // MARK: - Internal States

    @State private var internalSearchText: String = ""
    @State private var debounceCancellable: AnyCancellable? = nil
    @State private var showClearButton: Bool = false

    @State private var isFavoritesOn: Bool = false
    @State private var waveformDensityStep: Int = 1

    // Waveform density options (e.g. 0,1,2)
    private let densitySteps = [0, 1, 2]

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // Search Field with clear button and debounce
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(
                    "Search recordings",
                    text: $internalSearchText,
                    onEditingChanged: { _ in }
                )
                .textInputAutocapitalization(.none)
                .disableAutocorrection(true)
                .accessibilityLabel("Search recordings")
                .accessibilityHint("Enter search query to filter recordings")
                if showClearButton {
                    Button(
                        action: {
                            internalSearchText = ""
                            onSearch("")
                            updateClearButtonVisibility()
                        },
                        label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    )
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search text")
                }
            }
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .onChange(of: internalSearchText) { newValue in
                updateClearButtonVisibility()
                debounceSearch(text: newValue)
            }
            .onAppear {
                internalSearchText = searchText
                updateClearButtonVisibility()
            }

            // Theme toggle button
            Button(action: {
                onToggleTheme()
            }) {
                Image(systemName: "sun.max")
                    .foregroundColor(.primary)
            }
            .accessibilityLabel("Toggle light/dark theme")
            .buttonStyle(.bordered)

            // Favorites toggle button
            Button(action: {
                isFavoritesOn.toggle()
                onToggleFavorites()
            }) {
                Image(systemName: isFavoritesOn ? "star.fill" : "star")
                    .foregroundColor(isFavoritesOn ? .yellow : .primary)
            }
            .accessibilityLabel(isFavoritesOn ? "Favorites on" : "Favorites off")
            .buttonStyle(.bordered)

            // Waveform density picker
            Menu {
                ForEach(densitySteps, id: \.self) { step in
                    Button(action: {
                        waveformDensityStep = step
                        onWaveformDensity(step)
                    }) {
                        Text("Density \(step + 1)")
                        if step == waveformDensityStep {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(.primary)
            }
            .accessibilityLabel("Waveform density control")
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
        .frame(minHeight: 44)
    }

    // MARK: - Helpers

    private func updateClearButtonVisibility() {
        showClearButton = !internalSearchText.isEmpty
    }

    private func debounceSearch(text: String) {
        debounceCancellable?.cancel()
        debounceCancellable = Just(text)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink(receiveValue: { value in
                onSearch(value)
            })
    }
}

#if DEBUG
    struct SearchFilterPanel_Previews: PreviewProvider {
        struct PreviewWrapper: View {
            @State private var searchQuery: String = ""

            var body: some View {
                SearchFilterPanel(
                    searchText: $searchQuery,
                    onSearch: { query in
                        print("Search query: \(query)")
                    },
                    onToggleTheme: {
                        print("Theme toggled")
                    },
                    onToggleFavorites: {
                        print("Favorites toggled")
                    },
                    onWaveformDensity: { step in
                        print("Waveform density set to \(step)")
                    }
                )
                .padding()
                .previewLayout(.sizeThatFits)
            }
        }

        static var previews: some View {
            PreviewWrapper()
                .preferredColorScheme(.light)

            PreviewWrapper()
                .preferredColorScheme(.dark)
        }
    }
#endif
