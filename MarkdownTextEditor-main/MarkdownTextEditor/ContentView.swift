//
//  ContentView.swift
//  MarkdownTextEditor
//
//  Created by Rishi Kumar on 7/22/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct MarkdownHelpView: View {
    let markdownRules = [
        MarkdownRule(title: "Headings", 
                     description: "Use # for headings. More # means smaller heading.",
                     examples: [
                         "# Heading 1",
                         "## Heading 2",
                         "### Heading 3"
                     ]),
        MarkdownRule(title: "Emphasis", 
                     description: "Add emphasis to text with asterisks or underscores.",
                     examples: [
                         "*Italic*",
                         "_Italic_",
                         "**Bold**",
                         "__Bold__",
                         "***Bold and Italic***"
                     ]),
        MarkdownRule(title: "Lists", 
                     description: "Create ordered and unordered lists.",
                     examples: [
                         "- Unordered item",
                         "* Another unordered item",
                         "1. Ordered list item",
                         "2. Second ordered item"
                     ]),
        MarkdownRule(title: "Links", 
                     description: "Create hyperlinks with text and URL.",
                     examples: [
                         "[Link Text](https://example.com)",
                         "[Google](https://google.com)"
                     ]),
        MarkdownRule(title: "Code", 
                     description: "Highlight code inline or in blocks.",
                     examples: [
                         "`inline code`",
                         "```\nCode block\nMultiple lines\n```"
                     ]),
        MarkdownRule(title: "Blockquotes", 
                     description: "Create blockquotes with >",
                     examples: [
                         "> This is a blockquote",
                         "> Multiple line\n> blockquote"
                     ]),
        MarkdownRule(title: "Horizontal Rule", 
                     description: "Create a horizontal line with --- or ***",
                     examples: [
                         "---",
                         "***"
                     ])
    ]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(markdownRules) { rule in
                MarkdownRuleView(rule: rule)
            }
            .navigationTitle("Markdown Cheat Sheet")
            .navigationBarItems(trailing: 
                Button("Close") {
                    dismiss()
                }
            )
        }
    }
}

struct MarkdownRule: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let examples: [String]
}

struct MarkdownRuleView: View {
    let rule: MarkdownRule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(rule.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(rule.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(rule.examples, id: \.self) { example in
                    Text(example)
                        .font(.system(.caption, design: .monospaced))
                        .padding(4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ContentView: View {
    @State private var markdownText = ""
    @State private var fileName = "Untitled.md"
    @State private var isSaveDialogPresented = false
    @State private var isLoadDialogPresented = false
    @State private var savedFiles: [String] = []
    @State private var isPreviewMode = false
    @State private var fontSize: CGFloat = 14
    @State private var textColor = Color.primary
    @State private var backgroundColor = Color(uiColor: .secondarySystemBackground)
    @State private var isMarkdownHelpPresented = false
    
    private let fileManager = FileManager.default
    
    var body: some View {
        VStack {
            // Top Toolbar
            HStack {
                // File Operations
                Button(action: { isLoadDialogPresented = true }) {
                    Image(systemName: "folder")
                    Text("Open")
                }
                
                Button(action: { isSaveDialogPresented = true }) {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save")
                }
                
                // View Modes
                Picker("View", selection: $isPreviewMode) {
                    Text("Edit").tag(false)
                    Text("Preview").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Text Formatting
                Spacer()
                
                HStack {
                    Text("Font Size:")
                    Slider(value: $fontSize, in: 10...24, step: 1)
                        .frame(width: 100)
                    Text("\(Int(fontSize))")
                }
                
                // Help Button
                Button(action: showMarkdownHelp) {
                    Image(systemName: "questionmark.circle")
                    Text("Markdown Help")
                }
            }
            .padding()
            
            // Main Content Area
            HStack {
                // Markdown Input
                VStack {
                    Text("Markdown Editor")
                        .fontWeight(.bold)
                    
                    if !isPreviewMode {
                        TextEditor(text: $markdownText)
                            .font(.system(size: fontSize))
                            .foregroundColor(textColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Markdown Preview
                VStack {
                    Text("Output Preview")
                        .fontWeight(.bold)
                    
                    ScrollView {
                        Text(getAttributedString(markdownText))
                            .font(.system(size: fontSize))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            // Bottom Status Bar
            HStack {
                Text("File: \(fileName)")
                Spacer()
                Text("Characters: \(markdownText.count)")
                Text("Words: \(markdownText.split(whereSeparator: \.isWhitespace).count)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .sheet(isPresented: $isSaveDialogPresented) {
            SaveFileView(fileName: $fileName, markdownText: markdownText)
        }
        .sheet(isPresented: $isLoadDialogPresented) {
            LoadFileView(fileName: $fileName, markdownText: $markdownText)
        }
        .sheet(isPresented: $isMarkdownHelpPresented) {
            MarkdownHelpView()
        }
    }
    
    func getAttributedString(_ markdown: String) -> AttributedString {
        do {
            let attributedString = try AttributedString(markdown: markdown, options: .init(interpretedSyntax: .inlineOnlyUntilNewline))
            return attributedString
        } catch {
            print("Couldn't parse markdown: \(error)")
            return AttributedString("Error parsing markdown")
        }
    }
    
    private func showMarkdownHelp() {
        isMarkdownHelpPresented = true
    }
}

struct SaveFileView: View {
    @Binding var fileName: String
    let markdownText: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Save Markdown File")
                .font(.headline)
            
            TextField("File Name", text: $fileName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save") {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
                do {
                    try markdownText.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("File saved successfully at \(fileURL)")
                    dismiss()
                } catch {
                    print("Error saving file: \(error)")
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct LoadFileView: View {
    @Binding var fileName: String
    @Binding var markdownText: String
    @Environment(\.dismiss) private var dismiss
    @State private var availableFiles: [String] = []
    
    var body: some View {
        VStack {
            Text("Load Markdown File")
                .font(.headline)
            
            List(availableFiles, id: \.self) { file in
                Button(action: {
                    loadFile(named: file)
                }) {
                    Text(file)
                }
            }
            .onAppear {
                loadAvailableFiles()
            }
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private func loadAvailableFiles() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            availableFiles = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "md" }
                .map { $0.lastPathComponent }
        } catch {
            print("Error loading files: \(error)")
        }
    }
    
    private func loadFile(named file: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(file)
        
        do {
            markdownText = try String(contentsOf: fileURL, encoding: .utf8)
            fileName = file
            dismiss()
        } catch {
            print("Error loading file: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

