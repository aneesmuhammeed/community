import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/poll_model.dart';
import '../../../../core/providers/user_provider.dart';
import '../../data/home_repository.dart';

class PollCard extends ConsumerStatefulWidget {
  final PollModel poll;
  final bool hasVoted;
  final VoidCallback onVoteCast;

  const PollCard({
    Key? key,
    required this.poll,
    required this.hasVoted,
    required this.onVoteCast,
  }) : super(key: key);

  @override
  ConsumerState<PollCard> createState() => _PollCardState();
}

class _PollCardState extends ConsumerState<PollCard> {
  final HomeRepository _repository = HomeRepository();
  bool _isVoting = false;
  String? _selectedOptionId;

  Future<void> _submitVote() async {
    if (_selectedOptionId == null) return;
    setState(() => _isVoting = true);
    try {
      final user = ref.read(userProvider)!;
      await _repository.submitVote(widget.poll.id, _selectedOptionId!, user.residentId);
      widget.onVoteCast();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vote cast successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to vote: $e')));
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('POLL', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                ),
                const Spacer(),
                Text('Ends soon', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.poll.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (widget.poll.description != null && widget.poll.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(widget.poll.description!, style: TextStyle(color: Colors.grey[700])),
            ],
            const SizedBox(height: 16),
            ...widget.poll.options.map((opt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: widget.hasVoted
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(opt.optionText, style: const TextStyle(fontWeight: FontWeight.w500)),
                      )
                    : InkWell(
                        onTap: () => setState(() => _selectedOptionId = opt.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedOptionId == opt.id ? Theme.of(context).primaryColor : Colors.grey[300]!,
                              width: _selectedOptionId == opt.id ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedOptionId == opt.id ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: _selectedOptionId == opt.id ? Theme.of(context).primaryColor : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(opt.optionText, style: const TextStyle(fontWeight: FontWeight.w500))),
                            ],
                          ),
                        ),
                      ),
              );
            }),
            if (!widget.hasVoted) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_selectedOptionId == null || _isVoting) ? null : _submitVote,
                  child: _isVoting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Vote'),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              const Text('You have already voted on this poll.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
