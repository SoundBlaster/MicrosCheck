# 10. Developer TODO Dependency-Aware

ID	Task	Input/Output	Priority	Effort
P0	Define protocols & models (Sec.1)	Swift files + mocks	High	0.5d
P1	RecordingViewModel (state reducer)	Engine→Props mapping; actions→engine	High	1d
P2	A2 meters component	MeterLevels→bars; clip	High	0.5d
P3	A1 waveform renderer	stream→layer; timeline overlay	High	1.5d
P4	A5 transport	stop/rec/pause UI	High	0.5d
P5	A6 circular pad	play/seek/AB/DPC	High	1d
P6	A3 nav actions	back/home/mark/options	Medium	0.5d
P7	A7 lock/info	lock gate + help sheet	Medium	0.5d
P8	A4 search/filter	search field + toggles	Medium	0.5d
P9	Error/Toast component	reusable banner	Medium	0.5d
P10	Settings sheet	minimal options	Medium	0.5d
P11	Accessibility pass	labels, traits, Dynamic Type	High	0.5d
P12	Snapshot tests	key states per view	High	0.75d
P13	Performance tests	meter cadence, AB tolerance	High	0.75d
P14	Localization en/ru	strings + tests	Low	0.5d

## Dependencies

-	P1 depends on P0.
-	P3 depends on P0, P1 (timeline).
-	P5 depends on P1 (actions & timeline).
-	Test tasks (P12–P13) depend on corresponding views.