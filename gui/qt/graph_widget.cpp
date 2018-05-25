#include "graph_widget.h"

#include <QMessageBox>
#include <iostream>

graph_widget::graph_widget(QWidget * parent)
{
  int id = QFontDatabase::addApplicationFont(":dejavu_sans");
  QString family = QFontDatabase::applicationFontFamilies(id).at(0);
  font.setFamily(family);
  font2.setFamily(family);

  setup_ui();

  connect(domain, SIGNAL(valueChanged(int)),
    this, SLOT(change_ranges()));
}

// Changes options for the custom_plot when in preview mode.
void graph_widget::set_preview_mode(bool preview_mode)
{
  in_preview = preview_mode;

  if (preview_mode)
  {
    reset_graph_interaction_axes();

    custom_plot->setCursor(Qt::PointingHandCursor);
    custom_plot->setToolTip("Click to open graph window");
  }
  else
  {
    custom_plot->setCursor(Qt::ArrowCursor);
    custom_plot->setToolTip("");
  }

  for(auto plot : all_plots)
  {
    if (plot->display->isChecked())
    {
      plot->axis_label->setVisible(true);
      set_axis_text(*plot);
    }
  }

  custom_plot->replot();
}

void graph_widget::set_paused(bool paused)
{
  if (paused != graph_paused)
  {
    graph_paused = paused;
    pause_run_button->setText(graph_paused ? "R&un" : "&Pause");
    custom_plot->replot();
  }
}

void graph_widget::clear_graphs()
{
  for (auto plot : all_plots)
  {
    plot->graph->data()->clear();
  }

  custom_plot->replot();
}

void graph_widget::plot_data(uint32_t time)
{
  for (auto plot : all_plots)
  {
    plot->graph->addData(time, plot->plot_value);

    if (custom_plot->viewport().width() != viewport_width && plot->graph->visible())
    {
      set_axis_text(*plot);
    }
  }

  viewport_width = custom_plot->viewport().width();

  if (graph_paused)
    return;

  remove_data_to_scroll(time);
}

void graph_widget::setup_ui()
{
  pause_run_button = new QPushButton(this);
  pause_run_button->setObjectName("pause_run_button");
  pause_run_button->setText(tr("&Pause"));
  pause_run_button->setMinimumSize(pause_run_button->sizeHint());

  custom_plot = new QCustomPlot();
  custom_plot->axisRect()->setAutoMargins(QCP::msNone);
  custom_plot->setAntialiasedElements(QCP::aePlottables);
  custom_plot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom);
  custom_plot->axisRect()->setMargins(QMargins(50, 25, 40, 50));

  scale_validator = new QDoubleValidator(0.01, 1000000, 2);
  scale_validator->setNotation(QDoubleValidator::StandardNotation);

  connect(custom_plot, SIGNAL(mousePress(QMouseEvent*)),
    this, SLOT(mouse_press(QMouseEvent*)));

  domain = new QSpinBox();
  domain->setValue(10); // initialized the graph to show 10 seconds of data
  domain->setRange(1, 90);

  show_all_none = new QPushButton("Show all/none");
  show_all_none->setObjectName("show_all_none");
  show_all_none->setStyleSheet("QPushButton{padding: 4px;}");

  reset_all_button = new QPushButton(tr("Reset all"), this);
  reset_all_button->setStyleSheet("QPushButton{padding: 4px;}");
  reset_all_button->setObjectName("reset_all_button");
  reset_all_button->setToolTip("Reset all plots\nposition and scale");

  connect(show_all_none, SIGNAL(clicked()),
    this, SLOT(show_all_none_clicked()));

  plot_visible_layout = new QGridLayout();
  plot_visible_layout->addWidget(show_all_none, 0, 0);
  plot_visible_layout->addWidget(new QLabel("Position:"), 0, 1, Qt::AlignCenter);
  plot_visible_layout->addWidget(new QLabel("Scale:"), 0, 2, Qt::AlignCenter);
  plot_visible_layout->addWidget(reset_all_button, 0, 3, Qt::AlignLeft);

  QHBoxLayout * bottom_control_layout = new QHBoxLayout();
  bottom_control_layout->addWidget(new QLabel(tr(" Time (s):")), 0, Qt::AlignRight);
  bottom_control_layout->addWidget(domain, 0);
  bottom_control_layout->addWidget(pause_run_button, 0, Qt::AlignRight);

  setup_plot(input, "Input", "#00ffff", "#ff355e", 4095);

  setup_plot(target, "Target", "#0000ff", "#ff6037", 4095, true);

  setup_plot(feedback, "Feedback", "#ff8296", "#ffcc33", 4095);

  setup_plot(scaled_feedback, "Scaled feedback", "#ff0000", "#ccff00", 4095, true);

  setup_plot(error, "Error", "#9400d3", "#aaf0d1", 4095);

  setup_plot(integral, "Integral", "#ff8c00", "#ff6eff", 0x7fff);

  setup_plot(duty_cycle_target, "Duty cycle target", "#32cd32", "#fd5b78", 600);

  setup_plot(duty_cycle, "Duty cycle", "#006400", "#ff9933", 600);

  setup_plot(raw_current, "Raw current (mV)", "#660066", "#ffff66", 4095);

  setup_plot(current, "Current (mA)", "#b8860b", "#66ff66", 100000);

  setup_plot(current_chopping, "Current chopping", "#ff00ff", "#50bfe6", 1);

  QFrame * division_frame = new QFrame();
  division_frame->setFrameShadow(QFrame::Plain);
  division_frame->setLineWidth(0);
  division_frame->setFrameShape(QFrame::HLine);

  plot_visible_layout->addWidget(division_frame, row, 0, 1, 5);
  plot_visible_layout->addLayout(bottom_control_layout, ++row, 0, 1, 5, Qt::AlignCenter);

  QSharedPointer<QCPAxisTickerText> y_axis_ticker(new QCPAxisTickerText);

  y_axis_ticker->addTick(0, "");

  for (int i = 10; i <= 50; (i += 10))
  {
    y_axis_ticker->addTick(i, "");
    y_axis_ticker->addTick(-i, "");
  }

  y_axis_ticker->setSubTickCount(1);

  custom_plot->yAxis->setTicker(y_axis_ticker);
  custom_plot->yAxis->setTickLengthOut(3);

  custom_plot->xAxis->grid()->setPen(QPen(QColor(20, 20, 20, 140), 0, Qt::SolidLine));
  custom_plot->xAxis2->grid()->setPen(QPen(QColor(20, 20, 20, 140), 0, Qt::SolidLine));

  custom_plot->yAxis->grid()->setPen(QPen(QColor(20, 20, 20, 140), 0, Qt::SolidLine));
  custom_plot->yAxis->grid()->setSubGridPen(QPen(QColor(120, 120, 120, 110), 0, Qt::DashDotDotLine));
  custom_plot->yAxis->grid()->setZeroLinePen(QPen(QColor(20, 20, 20, 140), 0, Qt::SolidLine));
  custom_plot->yAxis->grid()->setSubGridVisible(true);
  custom_plot->yAxis->setSelectableParts(QCPAxis::spNone);

  custom_plot->yAxis->setRange(-50,50);
  custom_plot->xAxis->setTickLabelPadding(10);
  custom_plot->xAxis->setLabel("Time (ms)");
  custom_plot->xAxis->setLabelPadding(2);

  // this is used to see the x-axis to see accurate time.
  // custom_plot->xAxis2->setVisible(true);

  set_line_visible();

  custom_plot->axisRect()->setRangeDragAxes(0, 0);
  custom_plot->axisRect()->setRangeZoomAxes(0, 0);
  custom_plot->axisRect()->setRangeZoom(Qt::Vertical);


  QMetaObject::connectSlotsByName(this);
}

void graph_widget::setup_plot(plot& plot, QString display_text, QString default_color,
  QString dark_color, double scale, bool default_visible)
{
  plot.default_color = default_color;
  plot.dark_color = dark_color;

  plot.scale = new QDoubleSpinBox();
  plot.scale->setSingleStep(.1);
  plot.scale->setAccelerated(true);
  plot.scale->setRange(0.01, 1000000);
  plot.scale->setValue(scale/5.0);
  plot.scale->setFixedWidth(plot.scale->sizeHint().width());

  plot.scale_edit = new QLineEdit();
  plot.scale_edit = plot.scale->findChild<QLineEdit *>();
  plot.scale_edit->setValidator(scale_validator);

  connect(plot.scale, &QAbstractSpinBox::editingFinished, this, &graph_widget::fix_scale);

  emit plot.scale->editingFinished();

  plot.position = new QDoubleSpinBox();
  plot.position->setDecimals(1);
  plot.position->setSingleStep(0.1);
  plot.position->setMinimumWidth(plot.position->sizeHint().width());

  plot.position->setAccelerated(true);
  plot.position->setRange(-1000000, 1000000);

  plot.position->setValue(0);

  plot.display = new QCheckBox();
  plot.display->setText(display_text);
  plot.display->setStyleSheet("border: 2px solid "+ plot.default_color + ";"
    "padding: 2px;"
    "background-color: white;");
  plot.display->setCheckable(true);
  plot.display->setChecked(default_visible);

  plot.reset_button = new QPushButton();
  plot.reset_button->setIcon(QIcon(":reset_icon"));
  plot.reset_button->setStyleSheet("QPushButton{margin: 0px; padding: 3px;}");
  plot.reset_button->setToolTip("Reset " + display_text + " plot\nposition and scale");

  plot.axis = custom_plot->axisRect()->addAxis(QCPAxis::atLeft);
  plot.axis->setRange(-scale, scale);
  plot.axis->setVisible(false);

  font.setPointSize(25);

  plot.axis_label = new QCPItemText(custom_plot);
  plot.axis_label->setClipToAxisRect(false);
  plot.axis_label->setPositionAlignment(Qt::AlignRight | Qt::AlignVCenter);
  plot.axis_label->setFont(font);
  plot.axis_label->setColor(default_color);
  plot.axis_label->setText("\u27a4");
  plot.axis_label->position->setTypeX(QCPItemPosition::ptAxisRectRatio);
  plot.axis_label->position->setTypeY(QCPItemPosition::ptPlotCoords);
  plot.axis_label->position->setAxisRect(custom_plot->axisRect());
  plot.axis_label->position->setAxes(0, plot.axis);
  plot.axis_label->position->setCoords(0, 0);

  QFont axis_label_text;
  axis_label_text.setPointSize(8);

  plot.axis_position_label = new QCPItemText(custom_plot);
  plot.axis_position_label->setClipToAxisRect(false);
  plot.axis_position_label->setFont(axis_label_text);
  plot.axis_position_label->setColor(default_color);
  // plot.axis_position_label->position->setParentAnchor(plot.axis_label->top);
  // plot.axis_position_label->setPositionAlignment(Qt::AlignHCenter | Qt::AlignBottom);
  plot.axis_position_label->setTextAlignment(Qt::AlignCenter);
  plot.axis_position_label->setVisible(false);

  plot.axis_scale_label = new QCPItemText(custom_plot);
  plot.axis_scale_label->setClipToAxisRect(false);
  plot.axis_scale_label->setFont(axis_label_text);
  plot.axis_scale_label->setColor(default_color);
  // plot.axis_scale_label->position->setParentAnchor(plot.axis_label->bottom);
  // plot.axis_scale_label->setPositionAlignment(Qt::AlignHCenter | Qt::AlignTop);
  plot.axis_scale_label->setTextAlignment(Qt::AlignCenter);
  plot.axis_scale_label->setVisible(false);

  font2.setPointSize(20);

  QCPItemText * axis_top_label  = new QCPItemText(custom_plot);
  axis_top_label->setClipToAxisRect(false);
  axis_top_label->setPositionAlignment(Qt::AlignCenter);
  axis_top_label->setFont(font2);
  axis_top_label->setColor(default_color);
  axis_top_label->setText("\u27a4");
  axis_top_label->setRotation(270);
  axis_top_label->position->setTypeX(QCPItemPosition::ptAxisRectRatio);
  axis_top_label->position->setTypeY(QCPItemPosition::ptPlotCoords);
  axis_top_label->position->setAxisRect(custom_plot->axisRect());
  axis_top_label->position->setAxes(0, plot.axis);
  axis_top_label->setVisible(false);

  QCPItemText * axis_top_label2  = new QCPItemText(custom_plot);
  axis_top_label2->setClipToAxisRect(false);
  axis_top_label2->setPositionAlignment(Qt::AlignCenter);
  axis_top_label2->setFont(font2);
  axis_top_label2->setColor(default_color);
  axis_top_label2->setText("\u27a4");
  axis_top_label2->setRotation(270);
  axis_top_label2->position->setTypeX(QCPItemPosition::ptAxisRectRatio);
  axis_top_label2->position->setTypeY(QCPItemPosition::ptPlotCoords);
  axis_top_label2->position->setAxisRect(custom_plot->axisRect());
  axis_top_label2->position->setAxes(0, plot.axis);
  axis_top_label2->setVisible(false);

  QCPItemText * axis_top_label3  = new QCPItemText(custom_plot);
  axis_top_label3->setClipToAxisRect(false);
  axis_top_label3->setPositionAlignment(Qt::AlignCenter);
  axis_top_label3->setFont(font2);
  axis_top_label3->setColor(default_color);
  axis_top_label3->setText("\u27a4");
  axis_top_label3->setRotation(270);
  axis_top_label3->position->setTypeX(QCPItemPosition::ptAxisRectRatio);
  axis_top_label3->position->setTypeY(QCPItemPosition::ptPlotCoords);
  axis_top_label3->position->setAxisRect(custom_plot->axisRect());
  axis_top_label3->position->setAxes(0, plot.axis);
  axis_top_label3->setVisible(false);

  QCPItemText * axis_bottom_label  = new QCPItemText(custom_plot);
  axis_bottom_label->setClipToAxisRect(false);
  axis_bottom_label->setPositionAlignment(Qt::AlignCenter);
  axis_bottom_label->setFont(font2);
  axis_bottom_label->setColor(default_color);
  axis_bottom_label->setText("\u27a4");
  axis_bottom_label->setRotation(90);
  axis_bottom_label->position->setTypeX(QCPItemPosition::ptAxisRectRatio);
  axis_bottom_label->position->setTypeY(QCPItemPosition::ptPlotCoords);
  axis_bottom_label->position->setAxisRect(custom_plot->axisRect());
  axis_bottom_label->position->setAxes(0, plot.axis);
  axis_bottom_label->setVisible(false);

  QCPItemText * axis_bottom_label2  = new QCPItemText(custom_plot);
  axis_bottom_label2->setClipToAxisRect(false);
  axis_bottom_label2->setPositionAlignment(Qt::AlignCenter);
  axis_bottom_label2->setFont(font2);
  axis_bottom_label2->setColor(default_color);
  axis_bottom_label2->setText("\u27a4");
  axis_bottom_label2->setRotation(90);
  axis_bottom_label2->position->setTypeX(QCPItemPosition::ptAxisRectRatio);
  axis_bottom_label2->position->setTypeY(QCPItemPosition::ptPlotCoords);
  axis_bottom_label2->position->setAxisRect(custom_plot->axisRect());
  axis_bottom_label2->position->setAxes(0, plot.axis);
  axis_bottom_label2->setVisible(false);

  QCPItemText * axis_bottom_label3  = new QCPItemText(custom_plot);
  axis_bottom_label3->setClipToAxisRect(false);
  axis_bottom_label3->setPositionAlignment(Qt::AlignCenter);
  axis_bottom_label3->setFont(font2);
  axis_bottom_label3->setColor(default_color);
  axis_bottom_label3->setText("\u27a4");
  axis_bottom_label3->setRotation(90);
  axis_bottom_label3->position->setTypeX(QCPItemPosition::ptAxisRectRatio);
  axis_bottom_label3->position->setTypeY(QCPItemPosition::ptPlotCoords);
  axis_bottom_label3->position->setAxisRect(custom_plot->axisRect());
  axis_bottom_label3->position->setAxes(0, plot.axis);
  axis_bottom_label3->setVisible(false);

  plot.axis_top_and_bottom.append(axis_top_label);
  plot.axis_top_and_bottom.append(axis_bottom_label);
  plot.axis_top_and_bottom.append(axis_top_label2);
  plot.axis_top_and_bottom.append(axis_bottom_label2);
  plot.axis_top_and_bottom.append(axis_top_label3);
  plot.axis_top_and_bottom.append(axis_bottom_label3);

  plot_visible_layout->addWidget(plot.display, row, 0);
  plot_visible_layout->addWidget(plot.position, row, 1);
  plot_visible_layout->addWidget(plot.scale, row, 2);
  plot_visible_layout->addWidget(plot.reset_button, row, 3, Qt::AlignCenter);

  plot.graph = custom_plot->addGraph(custom_plot->xAxis2, plot.axis);
  plot.graph->setPen(QPen(QColor(plot.default_color), 1));
  plot.graph->setLineStyle(QCPGraph::lsStepCenter);

  connect(plot.reset_button, &QPushButton::clicked, [=]
  {
    plot.axis->setRange(-scale, scale);
  });

  connect(plot.display, &QCheckBox::toggled, [=](bool checked)
  {
    set_line_visible();

    custom_plot->replot();
  });

  connect(plot.axis, static_cast<void (QCPAxis::*)(const QCPRange&, const QCPRange&)>
    (&QCPAxis::rangeChanged), [=](const QCPRange & newRange, const QCPRange & oldRange)
  {
    double position_value = -(newRange.upper + newRange.lower)/2.0;
    double scale_value = (-newRange.lower + newRange.upper)/10;

    if (scale_value < 0.1)
    {
      plot.scale->setDecimals(2);
      plot.scale->setSingleStep(0.01);
    }
    else
    {
      plot.scale->setDecimals(1);
      plot.scale->setSingleStep(0.1);
    }

    if (scale_value < plot.scale->minimum() || scale_value > plot.scale->maximum()
      || position_value < plot.position->minimum() || position_value > plot.position->maximum())
    {
      plot.axis->setRange(oldRange);
    }

    {
      QSignalBlocker blocker(plot.position);
      plot.position->setValue(position_value);
    }

    {
      QSignalBlocker blocker(plot.scale);
      plot.scale->setValue(scale_value);
    }

    set_axis_text(plot);
  });

  connect(plot.scale_edit, static_cast<void (QLineEdit::*)(const QString&)>
    (&QLineEdit::textEdited), [=](const QString& value)
  {
    set_range(plot);
  });

  connect(plot.position, static_cast<void (QDoubleSpinBox::*)(const QString&)>
    (&QDoubleSpinBox::valueChanged), [=](const QString& value)
  {
    set_range(plot);
  });

  all_plots.append(&plot);

  row++;
}

// modifies the x-axis based on the domain value
// and removes data outside of visible scale
void graph_widget::remove_data_to_scroll(uint32_t time)
{
  key = time; // stores a local copy of time value

  custom_plot->xAxis->setRange(-domain->value() * 1000, 0);

  custom_plot->xAxis2->setRange(time, domain->value() * 1000, Qt::AlignRight);

  for (auto plot : all_plots)
  {
    plot->graph->data()->removeBefore(domain->value() * 1000);
  }

  custom_plot->replot();
}

void graph_widget::set_graph_interaction_axis(plot plot)
{
  plot.graph->setPen(QPen(plot.graph->pen().color(), 2));

  font.setPointSize(30);
  font2.setPointSize(25);

  plot.axis_label->setFont(font);

  plot.axis_position_label->setVisible(true);
  plot.axis_scale_label->setVisible(true);

  for (auto label : plot.axis_top_and_bottom)
    label->setFont(font2);

  custom_plot->axisRect()->setRangeDragAxes(0, plot.axis);
  custom_plot->axisRect()->setRangeZoomAxes(0, plot.axis);
}

// Clears selected axes from range drag and zoom.
void graph_widget::reset_graph_interaction_axes()
{
  custom_plot->axisRect()->setRangeDragAxes(0, 0);
  custom_plot->axisRect()->setRangeZoomAxes(0, 0);

  for (auto plot : all_plots)
  {
    plot->graph->setPen(QPen(plot->graph->pen().color(), 1));

    font.setPointSize(25);
    font2.setPointSize(20);

    plot->axis_label->setFont(font);

    plot->axis_position_label->setVisible(false);
    plot->axis_scale_label->setVisible(false);

    for (auto label : plot->axis_top_and_bottom)
      label->setFont(font2);
  }
}

void graph_widget::set_axis_text(plot plot)
{
  plot.axis_position_label->setText("Position:\n" + QString::number(plot.position->value(), 'f', 1) + "");
  plot.axis_scale_label->setText("Scale:\n" + QString::number(plot.scale->value(), 'f', 1) + "");

  if (plot.axis->range().lower >= 0)
  {
    plot.axis_label->setRotation(90);
    plot.axis_label->setPositionAlignment(Qt::AlignTop | Qt::AlignHCenter);

    if (plot.axis_position_label->visible())
      plot.axis_label->position->setCoords(-0.0025, plot.axis->range().lower);
    else
      plot.axis_label->position->setCoords(0.005, plot.axis->range().lower);


    plot.axis_scale_label->setPositionAlignment(Qt::AlignHCenter | Qt::AlignBottom);
    plot.axis_position_label->setPositionAlignment(Qt::AlignHCenter | Qt::AlignBottom);
    plot.axis_scale_label->position->setParentAnchor(plot.axis_label->left);
    plot.axis_position_label->position->setParentAnchor(plot.axis_scale_label->top);
  }
  else if (plot.axis->range().upper <= 0)
  {
    plot.axis_label->setRotation(270);
    plot.axis_label->setPositionAlignment(Qt::AlignBottom | Qt::AlignHCenter);
    plot.axis_label->position->setCoords(0, plot.axis->range().upper);

    plot.axis_scale_label->setPositionAlignment(Qt::AlignHCenter | Qt::AlignTop);
    plot.axis_position_label->setPositionAlignment(Qt::AlignHCenter | Qt::AlignTop);
    plot.axis_scale_label->position->setParentAnchor(plot.axis_position_label->bottom);
    plot.axis_position_label->position->setParentAnchor(plot.axis_label->left);
  }
  else
  {
    plot.axis_label->setRotation(0);
    plot.axis_label->setPositionAlignment(Qt::AlignRight | Qt::AlignVCenter);
    plot.axis_label->position->setCoords(-0.025, 0);

    plot.axis_scale_label->setPositionAlignment(Qt::AlignHCenter | Qt::AlignTop);
    plot.axis_position_label->setPositionAlignment(Qt::AlignHCenter | Qt::AlignBottom);
    plot.axis_scale_label->position->setParentAnchor(plot.axis_label->bottom);
    plot.axis_position_label->position->setParentAnchor(plot.axis_label->top);
  }

  bool out_top = false;
  bool out_bottom = false;
  QCPGraphDataContainer::const_iterator begin = plot.graph->data()->
    at(plot.graph->data()->dataRange().begin()); // get range begin iterator from index
  QCPGraphDataContainer::const_iterator end = plot.graph->data()->
    at(plot.graph->data()->dataRange().end()); // get range end iterator from index

  for (QCPGraphDataContainer::const_iterator it=begin; it!=end; ++it)
  {
    if (it->value > plot.axis->range().upper)
    {
      out_top = true;
    }

    if (it->value < plot.axis->range().lower)
    {
      out_bottom = true;
    }
  }

  int temp_width = custom_plot->viewport().width();

  temp_width = qBound(1, temp_width/350, 3);

  plot.axis_top_and_bottom[0]->setVisible(out_top);
  plot.axis_top_and_bottom[1]->setVisible(out_bottom);

  plot.axis_top_and_bottom[2]->setVisible(out_top && (temp_width > 1));
  plot.axis_top_and_bottom[3]->setVisible(out_bottom && (temp_width > 1));

  plot.axis_top_and_bottom[4]->setVisible(out_top && (temp_width > 2));
  plot.axis_top_and_bottom[5]->setVisible(out_bottom && (temp_width > 2));

  switch (temp_width)
  {
    case 1:
      plot.axis_top_and_bottom[0]->position->setCoords(0.50, plot.axis->range().upper);
      plot.axis_top_and_bottom[1]->position->setCoords(0.50, plot.axis->range().lower);
      break;
    case 2:
      plot.axis_top_and_bottom[0]->position->setCoords(0.20, plot.axis->range().upper);
      plot.axis_top_and_bottom[1]->position->setCoords(0.20, plot.axis->range().lower);
      plot.axis_top_and_bottom[2]->position->setCoords(0.80, plot.axis->range().upper);
      plot.axis_top_and_bottom[3]->position->setCoords(0.80, plot.axis->range().lower);
      break;
    case 3:
      plot.axis_top_and_bottom[0]->position->setCoords(0.20, plot.axis->range().upper);
      plot.axis_top_and_bottom[1]->position->setCoords(0.20, plot.axis->range().lower);
      plot.axis_top_and_bottom[2]->position->setCoords(0.50, plot.axis->range().upper);
      plot.axis_top_and_bottom[3]->position->setCoords(0.50, plot.axis->range().lower);
      plot.axis_top_and_bottom[4]->position->setCoords(0.80, plot.axis->range().upper);
      plot.axis_top_and_bottom[5]->position->setCoords(0.80, plot.axis->range().lower);
      break;
    default:
      break;
  }
}

void graph_widget::set_range(plot plot)
{
  plot.display->setCheckState(Qt::Checked);

  reset_graph_interaction_axes();

  double lower_range = -(plot.scale_edit->text().toDouble() * 5.0) - (plot.position->value());
  double upper_range = (plot.scale_edit->text().toDouble() * 5.0) - (plot.position->value());

  {
    QSignalBlocker blocker(plot.axis);
    plot.axis->setRange(lower_range, upper_range);
  }

  set_axis_text(plot);

  set_graph_interaction_axis(plot);
}

void graph_widget::change_ranges()
{
  custom_plot->xAxis->setRange(-domain->value() * 1000, 0);

  custom_plot->xAxis2->setRange(key, domain->value() * 1000, Qt::AlignRight);

  custom_plot->replot();
}

void graph_widget::on_pause_run_button_clicked()
{
  set_paused(!graph_paused);
}

void graph_widget::set_line_visible()
{
  for (auto plot : all_plots)
  {
    if (plot->display->isChecked())
    {
      plot->graph->setSelectable(QCP::stWhole);
    }
    else
    {
      plot->graph->setSelectable(QCP::stNone);
    }

    plot->graph->setVisible(plot->display->isChecked());
    plot->axis_label->setVisible(plot->display->isChecked());
    set_axis_text(*plot);
  }

  custom_plot->replot();
}

void graph_widget::show_all_none_clicked()
{
  bool all_checked = std::all_of(all_plots.begin(), all_plots.end(),
    [](const plot * plot) {return plot->display->isChecked();});

  for (auto plot : all_plots)
  {
    {
      QSignalBlocker blocker(plot->display);
      if (all_checked)
        plot->display->setChecked(false);
      else
        plot->display->setChecked(true);
    }
  }

  set_line_visible();
}

// Resets all position and scale values to default.
void graph_widget::on_reset_all_button_clicked()
{
  QMessageBox mbox(QMessageBox::Question, "",
    QString::fromStdString("Reset all positions and scales?"),
    QMessageBox::Ok | QMessageBox::Cancel);
  mbox.exec();

  if (QMessageBox::Ok)
  {
    for (auto plot : all_plots)
    {
      plot->reset_button->click();
    }

    custom_plot->replot();

    reset_graph_interaction_axes();
  }
  else
    return;
}

// This is a reimplementation of the QWidget::mousePressEvent slot.
// Due to the graph containing multiple scrolling plots, QCPAbstactPlottable::selectTest
// is used to determine the plot being selected.

void graph_widget::mouse_press(QMouseEvent * event)
{
  if (in_preview)
  {
    return;
  }

  reset_graph_interaction_axes();

  plot * temp_plot = Q_NULLPTR;

  int temp_view_height = custom_plot->viewport().height();

  if (event->localPos().x() < custom_plot->axisRect()->left())
  {
    double temp_axis_value = (double)temp_view_height * 0.02; // Selection tolerance for mouse press.

    for (auto plot : all_plots)
    {
      // Ignores plots which are not visible.
      if (plot->display->isChecked())
      {
        double select_test_value = plot->axis_label->selectTest(event->localPos(), false);

        if (qFabs(select_test_value) <= qFabs(temp_axis_value))
        {
          temp_plot = plot;
        }
      }
    }
  }
  else if (event->localPos().y() <= custom_plot->axisRect()->top())
  {
    double temp_axis_value = (double)temp_view_height * 2.0; // Selection tolerance for mouse press.

    for (auto plot : all_plots)
    {
      // Ignores plots which are not visible.
      if (plot->display->isChecked() && plot->axis_top_and_bottom[0]->visible())
      {
        double select_test_value = plot->axis_top_and_bottom[0]->selectTest(event->localPos(), false);

        if (qFabs(select_test_value) <= qFabs(temp_axis_value))
        {
          temp_plot = plot;
        }
      }
    }
  }
  else if (event->localPos().y() >= custom_plot->axisRect()->bottom())
  {
    double temp_axis_value = (double)temp_view_height * 2.0; // Selection tolerance for mouse press.

    for (auto plot : all_plots)
    {
      // Ignores plots which are not visible.
      if (plot->display->isChecked() && plot->axis_top_and_bottom[1]->visible())
      {
        double select_test_value = plot->axis_top_and_bottom[1]->selectTest(event->localPos(), false);

        if (qFabs(select_test_value) <= qFabs(temp_axis_value))
        {
          temp_plot = plot;
        }
      }
    }
  }
  else
  {
    double temp_value = 5;

    while (temp_plot == Q_NULLPTR && temp_value != 20)
    {
      for (auto plot : all_plots)
      {
        double select_test_value = plot->graph->selectTest(event->localPos(), true);

        if (select_test_value != -1 &&
          select_test_value <= temp_value)
        {
          temp_plot = plot;
        }
      }

      temp_value += 5;
    }
  }

  if (temp_plot != Q_NULLPTR)
  {
    set_graph_interaction_axis(*temp_plot);
  }
}

void graph_widget::fix_scale()
{
  QDoubleSpinBox * temp_spin;
  temp_spin = qobject_cast<QDoubleSpinBox*> (sender());

  QLineEdit * temp_line;
  temp_line = temp_spin->findChild<QLineEdit*>();

  double temp_value = temp_spin->value();
  QString temp_string = temp_line->text();

  if (!temp_string.contains("0.0"))
  {
    temp_spin->setDecimals(1);
    temp_spin->setSingleStep(0.1);
  }
  else
  {
    temp_spin->setDecimals(2);
    temp_spin->setSingleStep(0.01);
  }

  if (temp_string == "0.0")
  {
    temp_string = "0.01";
  }

  temp_line->setText(temp_string);
}
