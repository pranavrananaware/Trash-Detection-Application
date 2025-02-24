import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class ManageTrashReportsScreen extends StatelessWidget {
  /// **🔥 Generate and Open PDF with Clickable Location**
  Future<void> _generatePDF(BuildContext context, Map<String, dynamic> data) async {
    try {
      final pdf = pw.Document();

      // Extract Data
      String username = data['username'] ?? 'Unknown User';
      String location = data['location'] ?? 'Unknown Location';
      String detectedObject = data['detectedObject'] ?? 'Unknown';
      Timestamp? timestamp = data['timestamp'];
      String formattedDate = timestamp != null
          ? DateFormat.yMMMd().format(timestamp.toDate())
          : 'No Date Available';
      String imageUrl = data['imageUrl'] ?? '';

      // Load Image with Error Handling
      pw.Widget? imageWidget;
      if (imageUrl.isNotEmpty) {
        try {
          final image = await networkImage(imageUrl);
          imageWidget = pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Detected Image", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Image(image, height: 250, fit: pw.BoxFit.cover),
            ],
          );
        } catch (e) {
          print("Image loading error: $e");
        }
      }

      // Create PDF Page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("Trash Detection Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              _buildSectionTitle("User Details"),
              _buildDetailRow("User", username),
              _buildDetailRow("Location", location),
              pw.SizedBox(height: 10),
              _buildSectionTitle("Detection Details"),
              _buildDetailRow("Detected Object", detectedObject),
              _buildDetailRow("Timestamp", formattedDate),
              pw.SizedBox(height: 20),
              if (imageWidget != null) imageWidget,
            ],
          ),
        ),
      );

      // Get Storage Path
      Directory? output = await getApplicationDocumentsDirectory();
      if (output == null) {
        throw Exception("Storage directory not found.");
      }

      final filePath = "${output.path}/TrashReport_$username.pdf";
      final file = File(filePath);

      // Save PDF
      await file.writeAsBytes(await pdf.save());

      // Ensure File Exists Before Opening
      if (await file.exists()) {
        OpenFile.open(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Opening PDF: $filePath")),
        );
      } else {
        throw Exception("PDF not found at $filePath.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating PDF: $e")),
      );
    }
  }

  /// **Helper: Section Title**
  pw.Widget _buildSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
      ],
    );
  }

  /// **Helper: Detail Row with Clickable Google Maps Link**
  pw.Widget _buildDetailRow(String label, String value) {
    if (label == "Location" && value.isNotEmpty) {
      final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$value";
      return pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          children: [
            pw.Text("$label: ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.UrlLink(
              destination: googleMapsUrl,
              child: pw.Text(value, style: pw.TextStyle(fontSize: 14, color: PdfColors.blue, decoration: pw.TextDecoration.underline)),
            ),
          ],
        ),
      );
    }
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Text("$label: $value", style: pw.TextStyle(fontSize: 14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Trash Reports")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('trash_detections').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Reports Found"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildTrashReportCard(context, data);
            },
          );
        },
      ),
    );
  }

  /// **📌 Trash Report Card**
 Widget _buildTrashReportCard(BuildContext context, Map<String, dynamic> data) {
  String username = data['username'] ?? 'Unknown User';
  String location = data['location'] ?? 'Unknown Location';
  String detectedObject = data['detectedObject'] ?? 'Unknown';
  String imageUrl = data['imageUrl'] ?? '';

  return Card(
    margin: const EdgeInsets.all(8.0),
    elevation: 4.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
              )
            : const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
      title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("📍 Location: $location\n🔍 Detected: $detectedObject"),
      trailing: IconButton(
        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
        onPressed: () {
          _generatePDF(context, data);
        },
      ),
    ),
  );
}
}