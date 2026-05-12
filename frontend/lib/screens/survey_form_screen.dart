import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../services/survey_engine_core.dart';
import '../theme/app_theme.dart';
import '../widgets/questions/question_widgets.dart';

class SurveyFormScreen extends StatefulWidget {
  final String surveyId;
  final String respondentId;

  const SurveyFormScreen({
    super.key,
    required this.surveyId,
    required this.respondentId,
  });

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  late SurveyController _surveyController;
  late Survey _survey;
  late Respondent _respondent;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final appState = context.read<AppState>();
    _survey = appState.surveys.firstWhere((s) => s.id == widget.surveyId);
    _respondent = appState.getRespondents(widget.surveyId).firstWhere((r) => r.id == widget.respondentId);
    
    _surveyController = SurveyController(
      survey: _survey,
      initialAnswers: _respondent.answers,
    );
    
    _surveyController.addListener(() => setState(() {}));
    _initialized = true;
  }

  void _submit() async {
    if (!_surveyController.validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct errors before submitting')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final finalAnswers = _surveyController.getAllAnswers();
    await context.read<AppState>().submitRespondent(widget.surveyId, _respondent, finalAnswers);

    if (mounted) {
      Navigator.pop(context);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final tc = context.appColors;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          context.go('/respondents/${widget.surveyId}');
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.check_circle, color: AppColors.green, size: 72),
              const SizedBox(height: 24),
              Text('Response Saved!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: tc.textPrimary)),
              const SizedBox(height: 12),
              Text('Submission for ${_respondent.name} was successful.', textAlign: TextAlign.center, style: TextStyle(color: tc.textSub)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/respondents/${widget.surveyId}'),
                child: const Text('Back to Respondents'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final tc = context.appColors;
    final isReview = _surveyController.isReview;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _confirmExit()),
        title: Column(
          children: [
            Text('Survey Collection', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: tc.textSub)),
            Text(_survey.id, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tc.textPrimary)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              context.read<AppState>().saveRespondentDraft(widget.surveyId, _respondent, _surveyController.getAllAnswers());
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved successfully')));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(tc),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: isReview 
                    ? _buildReviewScreen(tc) 
                    : _buildQuestion(tc),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(tc),
    );
  }

  Widget _buildProgressIndicator(AppThemeColors tc) {
    final progress = (_surveyController.currentIndex + 1) / (_survey.questions.length + 1);
    return Column(
      children: [
        LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: tc.border),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Respondent: ${_respondent.name}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tc.textSub)),
              Text('Step ${_surveyController.currentIndex + 1} of ${_survey.questions.length + 1}', 
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tc.textSub)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(AppThemeColors tc) {
    final qc = _surveyController.currentQuestion;
    
    switch (qc.question.type) {
      case QuestionType.MultiChoiceSingleSelect:
        return SingleChoiceWidget(controller: qc);
      case QuestionType.MultiChoiceMultiSelect:
        return MultiChoiceWidget(controller: qc);
      case QuestionType.ChoiceWithAddition:
        return ChoiceWithAdditionWidget(controller: qc);
      case QuestionType.ChoiceWithFreeWriting:
        return ChoiceWithFreeWritingWidget(controller: qc);
      case QuestionType.OpenEnd:
        return OpenEndWidget(controller: qc);
      case QuestionType.Ranking:
        return RankingWidget(controller: qc);
      case QuestionType.PickingUp:
        return PickingUpWidget(controller: qc);
      case QuestionType.PickupAndRank:
        return PickupAndRankWidget(controller: qc);
      case QuestionType.RatingScale:
        return RatingScaleWidget(controller: qc);
      case QuestionType.Matrix:
        return MatrixWidget(controller: qc);
    }
  }

  Widget _buildReviewScreen(AppThemeColors tc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review Submission', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: tc.textPrimary)),
        const SizedBox(height: 8),
        Text('Please verify all details before submitting.', style: TextStyle(color: tc.textSub)),
        const SizedBox(height: 32),
        ..._surveyController.questions.map((qc) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(qc.question.text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: tc.textPrimary)),
              const SizedBox(height: 8),
              Text(
                AnswerParser.formatForDisplay(qc.question.type, qc.value),
                style: TextStyle(
                  color: qc.validate() ? AppColors.green : AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (qc.error != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(qc.error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                ),
              Divider(height: 32, color: tc.border),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildFooter(AppThemeColors tc) {
    final isReview = _surveyController.isReview;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(color: tc.surface, border: Border(top: BorderSide(color: tc.border))),
      child: Row(
        children: [
          if (!_surveyController.isFirst) ...[
            OutlinedButton(
              onPressed: _surveyController.previous,
              style: OutlinedButton.styleFrom(minimumSize: const Size(100, 52)),
              child: const Text('Back'),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: isReview ? _submit : _surveyController.next,
              child: Text(isReview ? 'Submit Response' : 'Next Step'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Survey?'),
        content: const Text('Your progress will be saved as a draft. You can continue later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AppState>().saveRespondentDraft(widget.surveyId, _respondent, _surveyController.getAllAnswers());
              Navigator.pop(context);
              context.go('/respondents/${widget.surveyId}');
            },
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
  }
}
