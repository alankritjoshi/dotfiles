/**
 * Plan Interview — tabbed Q&A interface for collaborative planning.
 *
 * The agent presents questions. The user answers, skips, or adds
 * their own. Returns answers and user questions for the agent to
 * process in the next turn.
 */

import type { ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Editor, type EditorTheme, Key, matchesKey, truncateToWidth, wrapTextWithAnsi } from "@mariozechner/pi-tui";

export interface PlanQuestion {
	id: string;
	question: string;
	context?: string;
}

interface AnsweredQuestion {
	id: string;
	question: string;
	answer: string;
}

export interface InterviewResult {
	answers: AnsweredQuestion[];
	userQuestions: string[];
	allSkipped: boolean;
}

export async function showPlanInterview(
	ctx: ExtensionContext,
	questions: PlanQuestion[],
): Promise<InterviewResult | null> {
	if (!ctx.hasUI) return null;

	const totalQuestions = questions.length;
	const DONE_TAB = totalQuestions;

	return ctx.ui.custom<InterviewResult | null>((tui, theme, _kb, done) => {
		let currentTab = 0;
		let editorActive = false;
		let addingQuestion = false;
		let cachedLines: string[] | undefined;

		const answers = new Map<string, string>();
		const skipped = new Set<string>();
		const userQuestions: string[] = [];

		const editorTheme: EditorTheme = {
			borderColor: (s: string) => theme.fg("accent", s),
			selectList: {
				selectedPrefix: (t: string) => theme.fg("accent", t),
				selectedText: (t: string) => theme.fg("accent", t),
				description: (t: string) => theme.fg("muted", t),
				scrollInfo: (t: string) => theme.fg("dim", t),
				noMatch: (t: string) => theme.fg("warning", t),
			},
		};
		const editor = new Editor(tui, editorTheme);

		function refresh() {
			cachedLines = undefined;
			tui.requestRender();
		}

		function currentQuestion(): PlanQuestion | undefined {
			return questions[currentTab];
		}

		function answeredCount(): number {
			return answers.size;
		}

		function advanceToNext() {
			if (currentTab < DONE_TAB) {
				currentTab++;
			}
			refresh();
		}

		function submitAnswer() {
			const text = editor.getText().trim();
			if (!text) return;

			const q = currentQuestion();
			if (q) {
				answers.set(q.id, text);
				skipped.delete(q.id);
			}

			editor.setText("");
			editorActive = false;
			advanceToNext();
		}

		function submitUserQuestion() {
			const text = editor.getText().trim();
			if (text) {
				userQuestions.push(text);
			}
			editor.setText("");
			addingQuestion = false;
			refresh();
		}

		function skipQuestion() {
			const q = currentQuestion();
			if (q) {
				skipped.add(q.id);
				answers.delete(q.id);
			}
			advanceToNext();
		}

		function finishInterview() {
			const result: InterviewResult = {
				answers: Array.from(answers.entries()).map(([id, answer]) => {
					const q = questions.find((qq) => qq.id === id);
					return { id, question: q?.question ?? id, answer };
				}),
				userQuestions,
				allSkipped: answers.size === 0 && userQuestions.length === 0,
			};
			done(result);
		}

		function handleInput(data: string) {
			if (editorActive || addingQuestion) {
				if (matchesKey(data, Key.escape)) {
					editor.setText("");
					editorActive = false;
					addingQuestion = false;
					refresh();
					return;
				}
				if (matchesKey(data, Key.ctrl("s")) || (matchesKey(data, Key.enter) && !editor.getText().includes("\n") && editor.getText().trim())) {
					if (addingQuestion) {
						submitUserQuestion();
					} else {
						submitAnswer();
					}
					return;
				}
				editor.handleInput(data);
				refresh();
				return;
			}

			if (matchesKey(data, Key.escape)) {
				done(null);
				return;
			}

			if (matchesKey(data, Key.tab) || matchesKey(data, Key.right) || matchesKey(data, "l")) {
				if (currentTab < DONE_TAB) {
					currentTab++;
					refresh();
				}
				return;
			}

			if (matchesKey(data, Key.shift("tab")) || matchesKey(data, Key.left) || matchesKey(data, "h")) {
				if (currentTab > 0) {
					currentTab--;
					refresh();
				}
				return;
			}

			if (currentTab === DONE_TAB) {
				if (matchesKey(data, Key.enter)) {
					finishInterview();
					return;
				}
				if (matchesKey(data, "a") || matchesKey(data, "q")) {
					addingQuestion = true;
					editor.setText("");
					refresh();
					return;
				}
				return;
			}

			if (matchesKey(data, Key.enter) || matchesKey(data, "a")) {
				editorActive = true;
				const existing = answers.get(currentQuestion()?.id ?? "");
				editor.setText(existing ?? "");
				refresh();
				return;
			}

			if (matchesKey(data, "s")) {
				skipQuestion();
				return;
			}
		}

		function render(width: number): string[] {
			if (cachedLines) return cachedLines;

			const lines: string[] = [];
			const add = (s: string) => lines.push(truncateToWidth(s, width));
			const addWrapped = (s: string) => {
				for (const line of wrapTextWithAnsi(s, width - 2)) {
					lines.push(truncateToWidth(` ${line}`, width));
				}
			};

			add(theme.fg("accent", "─".repeat(width)));

			// Tab bar
			const tabs: string[] = [];
			for (let i = 0; i < totalQuestions; i++) {
				const isActive = i === currentTab;
				const isAnswered = answers.has(questions[i].id);
				const isSkippedQ = skipped.has(questions[i].id);
				const label = ` Q${i + 1} `;

				if (isActive) {
					tabs.push(theme.bg("selectedBg", theme.fg("text", label)));
				} else if (isAnswered) {
					tabs.push(theme.fg("success", `✓${label}`));
				} else if (isSkippedQ) {
					tabs.push(theme.fg("dim", `–${label}`));
				} else {
					tabs.push(theme.fg("muted", ` ${label}`));
				}
			}

			const doneLabel = " Done ";
			if (currentTab === DONE_TAB) {
				tabs.push(theme.bg("selectedBg", theme.fg("text", doneLabel)));
			} else {
				tabs.push(theme.fg("muted", doneLabel));
			}

			add(` ${tabs.join(" ")}`);
			lines.push("");

			// Content
			if (editorActive || addingQuestion) {
				if (addingQuestion) {
					add(theme.fg("accent", " Add your question:"));
				} else {
					const q = currentQuestion();
					if (q) {
						addWrapped(theme.fg("text", q.question));
						if (q.context) {
							lines.push("");
							addWrapped(theme.fg("muted", q.context));
						}
					}
					lines.push("");
					add(theme.fg("accent", " Your answer:"));
				}
				lines.push("");
				for (const line of editor.render(width - 4)) {
					add(`  ${line}`);
				}
				lines.push("");
				add(theme.fg("dim", " Enter to submit • Esc to cancel"));
			} else if (currentTab === DONE_TAB) {
				const count = answeredCount();
				const uqCount = userQuestions.length;

				if (count > 0 || uqCount > 0) {
					add(theme.fg("accent", theme.bold(" Summary")));
					lines.push("");

					for (const [id, answer] of answers) {
						const q = questions.find((qq) => qq.id === id);
						const preview = answer.length > 60 ? `${answer.slice(0, 57)}...` : answer;
						add(` ${theme.fg("success", "✓")} ${theme.fg("muted", q?.question?.slice(0, 40) ?? id)}`);
						add(`   ${theme.fg("text", preview)}`);
					}

					for (const uq of userQuestions) {
						add(` ${theme.fg("accent", "?")} ${theme.fg("text", uq)}`);
					}
					lines.push("");
				}

				if (count === 0 && uqCount === 0 && totalQuestions > 0) {
					add(theme.fg("muted", " No questions answered yet."));
					lines.push("");
				}

				add(theme.fg("success", " Enter") + theme.fg("dim", " to finish • ") +
					theme.fg("accent", "a") + theme.fg("dim", " to add a question • ") +
					theme.fg("dim", "←→ to go back"));
			} else {
				const q = currentQuestion();
				if (q) {
					addWrapped(theme.fg("text", theme.bold(q.question)));
					if (q.context) {
						lines.push("");
						addWrapped(theme.fg("muted", q.context));
					}
					lines.push("");

					const existing = answers.get(q.id);
					if (existing) {
						add(` ${theme.fg("success", "✓ Answered:")} ${theme.fg("text", existing.length > 50 ? `${existing.slice(0, 47)}...` : existing)}`);
						lines.push("");
					}

					add(theme.fg("accent", " a") + theme.fg("dim", "nswer • ") +
						theme.fg("accent", "s") + theme.fg("dim", "kip • ") +
						theme.fg("dim", "←→ navigate • Esc cancel"));
				}
			}

			lines.push("");
			add(theme.fg("accent", "─".repeat(width)));

			cachedLines = lines;
			return lines;
		}

		return {
			render,
			invalidate: () => { cachedLines = undefined; },
			handleInput,
		};
	});
}
