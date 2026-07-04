# Tokyo Night colorscheme for ranger
# Save alongside rc.conf: ~/.config/ranger/colorschemes/tokyonight.py
# Enable with:  set colorscheme tokyonight
#
# Uses 256-color approximations of the Tokyo Night palette so it stays
# consistent with the waybar / sway / wofi theme.

from __future__ import absolute_import, division, print_function

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import (
    default,
    normal,
    bold,
    reverse,
    dim,
    default_colors,
)

# ---- Tokyo Night palette (xterm-256 indices) ----
BLUE    = 111   # #7aa2f7  directories, accents
CYAN    = 117   # #7dcfff  links
GREEN   = 149   # #9ece6a  executables, ok
MAGENTA = 141   # #bb9af7  media / special
YELLOW  = 179   # #e0af68  images, marks
ORANGE  = 215   # #ff9e64
RED     = 210   # #f7768e  errors, bad links
COMMENT = 60    # #565f89  borders, muted


class TokyoNight(ColorScheme):
    progress_bar_color = BLUE

    def use(self, context):  # noqa: C901 (structure mirrors ranger's default)
        fg, bg, attr = default_colors

        if context.reset:
            return default_colors

        elif context.in_browser:
            if context.selected:
                attr = reverse
            else:
                attr = normal

            if context.empty or context.error:
                bg = RED
            if context.border:
                fg = COMMENT
            if context.media:
                if context.image:
                    fg = YELLOW
                else:
                    fg = MAGENTA
            if context.container:
                fg = RED
            if context.directory:
                attr |= bold
                fg = BLUE
            elif context.executable and not \
                    any((context.media, context.container,
                         context.fifo, context.socket)):
                attr |= bold
                fg = GREEN
            if context.socket:
                attr |= bold
                fg = MAGENTA
            if context.fifo or context.device:
                fg = YELLOW
                if context.device:
                    attr |= bold
            if context.link:
                fg = CYAN if context.good else RED
            if context.tag_marker and not context.selected:
                attr |= bold
                fg = RED
            if not context.selected and (context.cut or context.copied):
                attr |= dim
                fg = COMMENT
            if context.main_column:
                if context.selected:
                    attr |= bold
                if context.marked:
                    attr |= bold
                    fg = YELLOW
            if context.badinfo:
                if attr & reverse:
                    bg = MAGENTA
                else:
                    fg = MAGENTA
            if context.inactive_pane:
                fg = COMMENT

        elif context.in_titlebar:
            attr |= bold
            if context.hostname:
                fg = RED if context.bad else GREEN
            elif context.directory:
                fg = BLUE
            elif context.tab:
                if context.good:
                    bg = BLUE
            elif context.link:
                fg = CYAN

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = GREEN
                elif context.bad:
                    fg = RED
            if context.marked:
                attr |= bold | reverse
                fg = YELLOW
            if context.frozen:
                attr |= bold | reverse
                fg = CYAN
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = RED
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = BLUE
                attr &= ~bold
            if context.vcscommit:
                fg = YELLOW
                attr &= ~bold

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = BLUE
            if context.selected:
                attr |= reverse
            if context.loaded:
                if context.selected:
                    fg = self.progress_bar_color
                else:
                    bg = self.progress_bar_color

        if context.vcsfile and not context.selected:
            attr &= ~bold
            if context.vcsconflict:
                fg = MAGENTA
            elif context.vcsuntracked:
                fg = CYAN
            elif context.vcschanged:
                fg = RED
            elif context.vcsunknown:
                fg = RED
            elif context.vcsstaged:
                fg = GREEN
            elif context.vcssync:
                fg = GREEN
            elif context.vcsignored:
                fg = default

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync or context.vcsnone:
                fg = GREEN
            elif context.vcsbehind:
                fg = RED
            elif context.vcsahead:
                fg = BLUE
            elif context.vcsdiverged:
                fg = MAGENTA
            elif context.vcsunknown:
                fg = RED

        return fg, bg, attr
