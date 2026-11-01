# User-selected pixel replacements

Direct byte copies from Downloads, no generative editing or recoloring:
- cannon_pixel_user_v2.png: supplied four-cell mortar shooting animation-2.
- reverse_pixel_user_4.png: supplied four-cell fortress reverse pixel animation.

4frames each. Cannon row boundary532 follows the real empty gutter, while hull uses2x2 regions. pixel_frames.json records measured bounds/anchors. All eight outer2px region borders contain zero opaque pixels at alpha200 inspection threshold. Source shape, palette and texture are preserved; nearest pixel sampling remains. Mortar base is about40% wider than previous live art; user requested noticeably larger cannon. Previous atlases retained but no longer referenced. No game/import/tests.
