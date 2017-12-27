#include "graph_window.h"
#include "main_window.h"
#include "graph_widget.h"

#include <QApplication>
#include <QCheckBox>
#include <QDebug>
#include <QDoubleSpinBox>
#include <QHBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QVBoxLayout>
#include <QWidget>

AltWindow::AltWindow(QWidget *parent)
{
	setup_ui();
	grabbedWidget = 0;
}

AltWindow::~AltWindow()
{

}

void AltWindow::setup_ui()
{
	setObjectName(QStringLiteral("AltWindow"));
	// resize(818,547);
	centralwidget = new QWidget(this);
	centralwidget->setObjectName(QStringLiteral("centralwidget"));
	verticalLayout = new QVBoxLayout(centralwidget);
	verticalLayout->setObjectName(QStringLiteral("verticalLayout"));

	centralLayout = new QGridLayout(this);

	mainLayout = new QGridLayout();

	plotLayout = new QHBoxLayout();

	bottomControlLayout = new QHBoxLayout();

	plotRangeLayout = new QVBoxLayout();

	plotVisibleLayout = new QVBoxLayout();

	range_label_layout = new QVBoxLayout();

	horizontal_layout = new QHBoxLayout();
	horizontal_layout->setObjectName(QStringLiteral("horizontal_layout"));

	verticalLayout->addLayout(horizontal_layout);


	retranslate_ui();

	QMetaObject::connectSlotsByName(this);
}

void AltWindow::closeEvent(QCloseEvent *event)
{
	grabbedWidget->custom_plot->xAxis->setTicks(false);
	grabbedWidget->custom_plot->yAxis->setTicks(false);
	horizontal_layout->removeWidget(grabbedWidget);
	emit pass_widget(grabbedWidget);
	grabbedWidget = 0;
	QWidget::closeEvent(event);
}

void AltWindow::receive_widget(graph_widget *widget)
{
	if(grabbedWidget != 0)
		qWarning() << "You might have lost a widget just now.";

	grabbedWidget = widget;
	bottomControlLayout->addWidget(grabbedWidget->pauseRunButton);
	bottomControlLayout->addWidget(grabbedWidget->label1);
	bottomControlLayout->addWidget(grabbedWidget->min_y);
	bottomControlLayout->addWidget(grabbedWidget->label3);
	bottomControlLayout->addWidget(grabbedWidget->max_y);
	bottomControlLayout->addWidget(grabbedWidget->label2);
	bottomControlLayout->addWidget(grabbedWidget->domain);
	grabbedWidget->custom_plot->xAxis->setTicks(true);
	grabbedWidget->custom_plot->yAxis->setTicks(true);
	grabbedWidget->custom_plot->setFixedSize(561,460);
	grabbedWidget->custom_plot->setCursor(Qt::ArrowCursor);
	grabbedWidget->custom_plot->setToolTip("");
	plotLayout->addWidget(grabbedWidget->custom_plot,Qt::AlignTop);

	for(auto &x: grabbedWidget->all_plots)
	{
		// graph_data_selection_bar->addWidget(x.plot_display);
		// graph_data_selection_bar->addWidget(x.range_label, Qt::AlignCenter);
		// graph_data_selection_bar->addWidget(x.plot_range);
		plotVisibleLayout->addLayout(x.graph_data_selection_bar);
	}

	mainLayout->addLayout(plotLayout,0,0,Qt::AlignTop);
	mainLayout->addLayout(bottomControlLayout,1,0);
	centralLayout->addLayout(mainLayout,0,0);
	centralLayout->addLayout(plotVisibleLayout,0,1);
	// centralLayout->addLayout(range_label_layout,0,2,Qt::AlignCenter);
	// centralLayout->addLayout(plotRangeLayout,0,3);


	horizontal_layout->addLayout(centralLayout);
}

void AltWindow::retranslate_ui()
{
	this->setWindowTitle(QApplication::translate("AltWindow", "Pololu jrk G2 Configuration Utility - Plots of Variables vs. Time", Q_NULLPTR));
}
