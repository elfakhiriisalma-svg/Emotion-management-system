import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/emotion_model.dart';
import '../models/employee_note_model.dart';

class PdfReportService {
  Future<void> generateEmployeeReport({
    required UserModel employee,
    required List<EmotionModel> emotions,
    required List<EmployeeNoteModel> notes,
    required Map<String, int> emotionFrequency,
    required int stressLevel,
    required String mostFrequentEmotion,
  }) async {
    final pdf = pw.Document();

    // Calculate weekly trend data
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklyEmotions = emotions
        .where((e) => e.timestamp.isAfter(weekAgo))
        .toList();

    // Group by day
    final dailyCounts = <String, int>{};
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var emotion in weeklyEmotions) {
      final dayKey = DateFormat('EEE').format(emotion.timestamp);
      dailyCounts[dayKey] = (dailyCounts[dayKey] ?? 0) + 1;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(employee),
            pw.SizedBox(height: 20),

            // Employee Information
            _buildEmployeeInfo(employee, emotions.length, stressLevel),
            pw.SizedBox(height: 20),

            // Emotion Histogram
            _buildEmotionHistogram(emotionFrequency),
            pw.SizedBox(height: 20),

            // Weekly Trend
            _buildWeeklyTrend(dailyCounts, days),
            pw.SizedBox(height: 20),

            // Notes Section
            _buildNotesSection(notes),
            pw.SizedBox(height: 20),

            // Recommendations
            _buildRecommendations(emotions, stressLevel, mostFrequentEmotion),
          ];
        },
      ),
    );

    // Show print dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildHeader(UserModel employee) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Employee Emotion Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on ${DateFormat('MMMM dd, yyyy • HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEmployeeInfo(UserModel employee, int totalEmotions, int stressLevel) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Employee Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Name', employee.fullName),
          _buildInfoRow('Email', employee.email),
          if (employee.age != null) _buildInfoRow('Age', employee.age.toString()),
          if (employee.gender != null) _buildInfoRow('Gender', employee.gender!),
          pw.Divider(),
          _buildInfoRow('Total Emotions Recorded', totalEmotions.toString()),
          _buildInfoRow('Stress Level', '$stressLevel%'),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEmotionHistogram(Map<String, int> emotionFrequency) {
    final emotionTypes = ['HAPPY', 'SAD', 'ANGRY', 'FEAR', 'NEUTRAL'];
    final maxCount = emotionFrequency.values.isEmpty
        ? 1
        : emotionFrequency.values.reduce((a, b) => a > b ? a : b);

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Emotion Frequency Distribution',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 15),
          ...emotionTypes.map((emotion) {
            final count = emotionFrequency[emotion] ?? 0;
            final percentage = maxCount > 0 ? (count / maxCount * 100) : 0.0;
            
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        emotion,
                        style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('$count (${percentage.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Stack(
                    children: [
                      pw.Container(
                        height: 20,
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                      ),
                      pw.Positioned(
                        left: 0,
                        top: 0,
                        child: pw.Container(
                          height: 20,
                          width: 400 * (percentage / 100),
                          decoration: pw.BoxDecoration(
                            color: _getEmotionColor(emotion),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  pw.Widget _buildWeeklyTrend(Map<String, int> dailyCounts, List<String> days) {
    final maxCount = dailyCounts.values.isEmpty
        ? 1
        : dailyCounts.values.reduce((a, b) => a > b ? a : b);

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Weekly Trend (Last 7 Days)',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: days.map((day) {
              final count = dailyCounts[day] ?? 0;
              final height = maxCount > 0 ? (count / maxCount * 100) : 0.0;
              
              return pw.Expanded(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      height: height,
                      margin: const pw.EdgeInsets.symmetric(horizontal: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue700,
                        borderRadius: const pw.BorderRadius.vertical(
                          top: pw.Radius.circular(4),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      day,
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      count.toString(),
                      style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildNotesSection(List<EmployeeNoteModel> notes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Manager Notes (${notes.length})',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          if (notes.isEmpty)
            pw.Text(
              'No notes available for this employee.',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            )
          else
            ...notes.map((note) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Dr. ${note.managerName}',
                          style: const pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        pw.Text(
                          DateFormat('MMM dd, yyyy HH:mm').format(note.createdAt),
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      note.note,
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  pw.Widget _buildRecommendations(
    List<EmotionModel> emotions,
    int stressLevel,
    String mostFrequentEmotion,
  ) {
    final recommendations = <String>[];

    // Analyze emotions and generate recommendations
    if (stressLevel >= 75) {
      recommendations.add(
        'High stress level detected (${stressLevel}%). Consider scheduling a consultation to discuss stress management strategies.'
      );
    } else if (stressLevel >= 50) {
      recommendations.add(
        'Moderate stress level (${stressLevel}%). Regular monitoring and stress-reduction activities are recommended.'
      );
    }

    if (mostFrequentEmotion == 'SAD') {
      recommendations.add(
        'Sadness is the most frequently detected emotion. Consider discussing mood support strategies and potential interventions.'
      );
    } else if (mostFrequentEmotion == 'ANGRY') {
      recommendations.add(
        'Anger is frequently detected. Anger management techniques and coping strategies may be beneficial.'
      );
    } else if (mostFrequentEmotion == 'FEAR') {
      recommendations.add(
        'Fear is frequently detected. Consider addressing anxiety triggers and providing reassurance.'
      );
    }

    // Check for negative emotion patterns
    final negativeEmotions = emotions.where((e) =>
        e.emotionType == 'SAD' ||
        e.emotionType == 'ANGRY' ||
        e.emotionType == 'FEAR').length;
    
    if (negativeEmotions > emotions.length * 0.6) {
      recommendations.add(
        'More than 60% of recorded emotions are negative. A comprehensive mental health assessment may be warranted.'
      );
    }

    // General recommendations
    if (emotions.length < 10) {
      recommendations.add(
        'Limited emotion data available. Encourage regular emotion tracking for better insights.'
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'Employee shows a balanced emotional pattern. Continue regular monitoring and maintain current care plan.'
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Recommendations',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          ...recommendations.asMap().entries.map((entry) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 20,
                    height: 20,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue700,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '${entry.key + 1}',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Text(
                      entry.value,
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  PdfColor _getEmotionColor(String emotionType) {
    switch (emotionType) {
      case 'HAPPY':
        return PdfColors.green;
      case 'SAD':
        return PdfColors.blue;
      case 'ANGRY':
        return PdfColors.red;
      case 'FEAR':
        return PdfColors.orange;
      default:
        return PdfColors.grey;
    }
  }
}

