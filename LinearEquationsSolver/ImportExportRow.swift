import SwiftUI
import UniformTypeIdentifiers

struct CoeficientsDocument : FileDocument, Codable {
    var selectedNumberOfEquations: Int
    var coeficients: [[Double]]
    
    init(_ number: Int, _ coefs: [[Double]]) {
        self.selectedNumberOfEquations = number
        self.coeficients = coefs
    }
    
    static public var readableContentTypes: [UTType] = [.json]
    
    init(configuration: ReadConfiguration) throws {
        self.selectedNumberOfEquations = 0
        self.coeficients = [[]]
    }
    
    func fileWrapper(configuration: WriteConfiguration)
        throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(self)
        print(String(data: data, encoding: .utf8)!)
        return FileWrapper(regularFileWithContents: data)
    }
}

struct ImportFileButton: View {
    @Binding var selectedNumberOfEquations: NumberOfEquations
    @Binding var coeficients: [[Double]]
    
    @State private var isImporting = false
    
    var body: some View {
     Button {
       isImporting = true
     } label: {
       Label("File import", systemImage: "square.and.arrow.down")
     }
     .buttonStyle(.plain)
     .fileImporter(
         isPresented: $isImporting,
         allowedContentTypes: [.json]
     ) { result in
         switch result {
         case .success(let file):
             // gain access to the directory
             let gotAccess = file.startAccessingSecurityScopedResource()
             if !gotAccess { return }
             let data = try? Data(contentsOf: file)
             if let data {
                 let decoder = JSONDecoder()
                 let doc = try? decoder.decode(CoeficientsDocument.self, from: data)
                 if let doc {
                     selectedNumberOfEquations = NumberOfEquations(rawValue: doc.selectedNumberOfEquations) ?? .Two
                     coeficients = doc.coeficients
                     print(selectedNumberOfEquations)
                     print(coeficients)
                 }
             }
             file.stopAccessingSecurityScopedResource()
         case .failure(let error):
             print(error)
        }
        }
    }
}

struct ExportFileButton: View {
    var selectedNumberOfEquations: NumberOfEquations
    var coeficients: [[Double]]
    
    @State private var isExporting = false
    
    var body: some View {
        Button {
            isExporting = true
        } label: {
            Label("File export", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.plain)
        .fileExporter(isPresented: $isExporting,
                      document: CoeficientsDocument(selectedNumberOfEquations.rawValue, coeficients),
                      contentType: .json,
                      defaultFilename: "coeficients") { result in
            if case .failure(let error) = result {
                print(error)
            }
        }
    }
}

struct ImportExportButtonsRow: View {
    @Binding var selectedNumberOfEquations: NumberOfEquations
    @Binding var coeficients: [[Double]]
    
    var body: some View {
        HStack {
            Spacer()
            ImportFileButton(selectedNumberOfEquations: $selectedNumberOfEquations, coeficients: $coeficients)
            Spacer()
            ExportFileButton(selectedNumberOfEquations: selectedNumberOfEquations, coeficients: coeficients)
            Spacer()
        }
    }
}
